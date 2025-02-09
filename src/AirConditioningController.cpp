#include <ArduinoJson.h>

#include "AirConditioningController.hpp"

AirConditioningController::AirConditioningController(char* deviceId,
                                                     WiFiClient* wifi,
                                                     HeatPump* hp,
                                                     uint8_t rxPin,
                                                     uint8_t txPin,
                                                     uint8_t userLedPin,
                                                     uint8_t userBtnPin) {
  this->deviceId = deviceId;

  this->rxPin = rxPin;
  this->txPin = txPin;
  this->userLedPin = userLedPin;
  this->userBtnPin = userBtnPin;

  Serial.println("Setting up stuff");
  this->mqtt = new MQTTClient(deviceId);
  this->mqtt->setWiFiClient(*wifi);
  this->hp = hp;

  this->pubSubTopicSettings = "ac/settings";
  this->pubSubTopicStatus = "ac/status";
  this->pubSubTopicTimers = "ac/timers";
  this->pubSubTopicDebug = "ac/debug";
}

AirConditioningController::~AirConditioningController() {
  if (mqtt != nullptr) {
    delete mqtt;
  }
  if (hk != nullptr) {
    delete hk;
  }
}

void AirConditioningController::setup() {
  Serial.println("Initializing Air Conditioning Controller");

  hp->setFastSync(true);
  // NOTE: Configs set by IR remote should still remain
  hp->enableExternalUpdate();

  // NOTE: `setPacketCallback` should be called before `connect`
  // so the initial packets will also be logged.
  Serial.println("Setting up callbacks");
  hp->setSettingsChangedCallback(
      std::bind(&AirConditioningController::handleSettingsChanged, this));
  hp->setStatusChangedCallback(
      std::bind(&AirConditioningController::handleStatusChanged, this,
                std::placeholders::_1));
  hp->setPacketCallback(std::bind(
      &AirConditioningController::handlePacketReceived, this,
      std::placeholders::_1, std::placeholders::_2, std::placeholders::_3));

  Serial.println("Connecting to UART1");
  Serial1.begin(2400, SERIAL_8E1, rxPin, txPin);
  hp->connect(&Serial1);

  // Set up HomeKit device
  homeSpan.setLogLevel(2);
  homeSpan.setControlPin(userBtnPin);
  homeSpan.setStatusPin(userLedPin);
  homeSpan.setStatusAutoOff(10);  // 10s
  homeSpan.begin(Category::AirConditioners, "Mitsubishi Electric",
                 deviceId);  // TODO: Must be unique?

  new SpanAccessory();
  new Service::AccessoryInformation();
  new Characteristic::Identify();
  new Characteristic::Name("Air Conditioner");
  new Characteristic::Manufacturer("Mitsubishi Electric");
  // new Characteristic::Model("");
  new Characteristic::FirmwareRevision("0.1.0");

  // FIXME: Why this cannot be called in the constructor?
  this->hk = new HomeKitAirConditioner();

  hk->setStateUpdateCallback(
      std::bind(&AirConditioningController::handleHomeKitPowerUpdated, this,
                std::placeholders::_1));
  hk->setModeUpdateCallback(
      std::bind(&AirConditioningController::handleHomeKitTargetStateUpdated,
                this, std::placeholders::_1));
  hk->setOscillationUpdateCallback(
      std::bind(&AirConditioningController::handleHomeKitSwingModeUpdated, this,
                std::placeholders::_1));
  hk->setFanSpeedUpdateCallback(
      std::bind(&AirConditioningController::handleHomeKitRotationSpeedUpdated,
                this, std::placeholders::_1));
  hk->setTempCoolUpdateCallback(
      std::bind(&AirConditioningController::handleHomeKitTargetTempCoolUpdated,
                this, std::placeholders::_1));

  Serial.println("Completed setup for Air Conditioning Controller");
}

void AirConditioningController::loop() {
  mqtt->tryConnect();

#ifdef DEBUG
  uint32_t currentTime = millis();
  if (currentTime - lastDebugPublished > 10000) {
    float chipTemp = temperatureRead();
    char message[40];
    snprintf(message, sizeof(message), "Retrieved ESP32 temperature: %.1f°C",
             chipTemp);
    Serial.println(message);
    publish(pubSubTopicDebug, message);
    lastDebugPublished = currentTime;
  }
#endif

  hp->sync();
  homeSpan.poll();
}

void AirConditioningController::publish(const char* topic,
                                        const char* payload) {
  if (mqtt->isConnected() && !mqtt->publish(topic, payload)) {
    char errorMessage[512];
    snprintf(errorMessage, sizeof(errorMessage),
             "failed to publish to topic: %s: %s", topic, payload);
    Serial.println(errorMessage);
    mqtt->publish(pubSubTopicDebug, errorMessage);
  }
}

void AirConditioningController::publishSettings(heatpumpSettings current) {
  JsonDocument payload;
  payload["power"] = current.power;
  payload["mode"] = current.mode;
  payload["temperature"] = current.temperature;
  payload["fan"] = current.fan;
  payload["vane"] = current.vane;
  payload["wideVane"] = current.wideVane;

  char buffer[512];
  serializeJson(payload, buffer);
  publish(pubSubTopicSettings, buffer);
}

void AirConditioningController::publishStatus(heatpumpStatus current) {
  JsonDocument payload;
  payload["roomTemperature"] = current.roomTemperature;
  payload["operating"] = current.operating;
  payload["compressorFrequency"] = current.compressorFrequency;

  char buffer[512];
  serializeJson(payload, buffer);
  publish(pubSubTopicStatus, buffer);
}

void AirConditioningController::publishTimers(heatpumpTimers current) {
  JsonDocument payload;
  payload["mode"] = current.mode;
  payload["onMins"] = current.onMinutesSet;
  payload["onRemainMins"] = current.onMinutesRemaining;
  payload["offMins"] = current.offMinutesSet;
  payload["offRemainMins"] = current.offMinutesRemaining;

  char buffer[512];
  serializeJson(payload, buffer);
  publish(pubSubTopicTimers, buffer);
}

void AirConditioningController::publishPacket(byte* packet,
                                              unsigned int length,
                                              char* direction) {
  String message;
  for (int idx = 0; idx < length; idx++) {
    if (packet[idx] < 16) {
      message += "0";  // pad single hex digits with a 0
    }
    message += String(packet[idx], HEX) + " ";
  }

  JsonDocument payload;
  payload[direction] = message;

  char buffer[512];
  serializeJson(payload, buffer);
  publish(pubSubTopicDebug, buffer);
}

void AirConditioningController::handleSettingsChanged() {
  heatpumpSettings current = hp->getSettings();
  publishSettings(current);

  handleHeatPumpPowerUpdated(current.power);
  handleHeatPumpModeUpdated(current.mode);
  handleHeatPumpVaneUpdated(current.vane);
  handleHeatPumpFanUpdated(current.fan);
  handleHeatPumpTempUpdated(current.temperature);
}
void AirConditioningController::handleStatusChanged(heatpumpStatus status) {
  publishStatus(status);
  publishTimers(status.timers);

  handleHeatPumpRoomTemperatureUpdated(status.roomTemperature);
}
void AirConditioningController::handlePacketReceived(byte* packet,
                                                     unsigned int length,
                                                     char* direction) {
  publishPacket(packet, length, direction);
}

void AirConditioningController::handleHeatPumpRoomTemperatureUpdated(
    float roomTemperature) {
  char message[64];
  snprintf(message, sizeof(message),
           "HeatPump: Room Temperature updated to: %0.1f°C", roomTemperature);
  Serial.println(message);
  publish(pubSubTopicDebug, message);

  hk->setCurrentTemp(roomTemperature);
}
void AirConditioningController::handleHeatPumpPowerUpdated(const char* power) {
  char message[64];
  snprintf(message, sizeof(message), "HeatPump: Power updated to: %s", power);
  Serial.println(message);
  publish(pubSubTopicDebug, message);

  hk->setCurrentState(heatPumpPowerToHomeKitActive(power));
}
void AirConditioningController::handleHeatPumpModeUpdated(const char* mode) {
  char message[64];
  snprintf(message, sizeof(message), "HeatPump: Mode updated to: %s", mode);
  Serial.println(message);
  publish(pubSubTopicDebug, message);

  hk->setCurrentMode(heatPumpModetoHomeKitTargetState(mode));
}
void AirConditioningController::handleHeatPumpVaneUpdated(const char* vane) {
  char message[64];
  snprintf(message, sizeof(message), "HeatPump: Vane updated to: %s", vane);
  Serial.println(message);
  publish(pubSubTopicDebug, message);

  hk->setCurrentOscillation(heatPumpVaneToHomeKitSwingMode(vane));
}
void AirConditioningController::handleHeatPumpFanUpdated(const char* fan) {
  char message[64];
  snprintf(message, sizeof(message), "HeatPump: Fan Speed updated to: %s", fan);
  Serial.println(message);
  publish(pubSubTopicDebug, message);

  hk->setCurrentFanSpeed(heatPumpFanToHomeKitRotationSpeed(fan));
}
void AirConditioningController::handleHeatPumpTempUpdated(float temp) {
  char message[64];
  snprintf(message, sizeof(message),
           "HeatPump: Temperature updated to: %0.1f°C", temp);
  Serial.println(message);
  publish(pubSubTopicDebug, message);

  hk->setCurrentTempCool(heatPumpTempToHomeKitTargetTempCool(temp));
}

void AirConditioningController::handleHomeKitPowerUpdated(bool active) {
  char message[64];
  snprintf(message, sizeof(message), "HomeKit: Power updated to: %s",
           active ? "ON" : "OFF");
  Serial.println(message);
  publish(pubSubTopicDebug, message);

  hp->setPowerSetting(homeKitActiveToHeatPumpPower(active));
}
void AirConditioningController::handleHomeKitTargetStateUpdated(
    int targetState) {
  char message[64];
  snprintf(message, sizeof(message), "HomeKit: Target State updated to: %d",
           targetState);
  Serial.println(message);
  publish(pubSubTopicDebug, message);

  hp->setModeSetting(homeKitTargetStateToHeatPumpMode(targetState));
}
void AirConditioningController::handleHomeKitSwingModeUpdated(bool swingMode) {
  char message[64];
  snprintf(message, sizeof(message), "HomeKit: Swing Mode updated to: %s",
           swingMode ? "ON" : "OFF");
  Serial.println(message);
  publish(pubSubTopicDebug, message);

  hp->setVaneSetting(homeKitSwingModeToHeatPumpVane(swingMode));
}
void AirConditioningController::handleHomeKitRotationSpeedUpdated(
    float rotationSpeed) {
  char message[64];
  snprintf(message, sizeof(message), "HomeKit: Rotation Speed updated to: %f",
           rotationSpeed);
  Serial.println(message);
  publish(pubSubTopicDebug, message);

  hp->setFanSpeed(homeKitRotationSpeedToHeatPumpFan(rotationSpeed));
}
void AirConditioningController::handleHomeKitTargetTempCoolUpdated(
    float targetTempCool) {
  char message[64];
  snprintf(message, sizeof(message),
           "HomeKit: Target Cool Temperature updated to: %0.1f",
           targetTempCool);
  Serial.println(message);
  publish(pubSubTopicDebug, message);

  hp->setTemperature(homeKitTargetTempCoolToHeatPumpTemp(targetTempCool));
}

const char* homeKitActiveToHeatPumpPower(bool active) {
  return active ? "ON" : "OFF";
}
bool heatPumpPowerToHomeKitActive(const char* power) {
  return strcmp(power, "ON") == 0;
}

const char* homeKitTargetStateToHeatPumpMode(int targetState) {
  if (targetState == 0) {
    return "AUTO";
  }
  if (targetState == 1) {
    return "HEAT";
  }
  if (targetState == 2) {
    return "COOL";
  }
  return "AUTO";
}
int heatPumpModetoHomeKitTargetState(const char* mode) {
  if (strcmp(mode, "AUTO") == 0) {
    return 0;
  }
  if (strcmp(mode, "HEAT") == 0) {
    return 1;
  }
  if (strcmp(mode, "COOL") == 0) {
    return 2;
  }
  return 0;
}

const char* homeKitSwingModeToHeatPumpVane(bool swingMode) {
  // NOTE: HomeKit `SwingMode` characteristic only supports
  // binary state. If not oscillating, we set the vane position to 1.
  return swingMode ? "SWING" : "1";
}
bool heatPumpVaneToHomeKitSwingMode(const char* vane) {
  return strcmp(vane, "SWING") == 0;
}

const char* homeKitRotationSpeedToHeatPumpFan(float rotationSpeed) {
  // NOTE: HeatPump only accepts speed range of 1-5.
  if (rotationSpeed <= 1.5f) {
    return "1";
  }
  if (rotationSpeed <= 2.5f) {
    return "2";
  }
  if (rotationSpeed <= 3.5f) {
    return "3";
  }
  if (rotationSpeed <= 4.5f) {
    return "4";
  }
  return "5";
}
float heatPumpFanToHomeKitRotationSpeed(const char* fan) {
  if (strcmp(fan, "1") == 0 || strcmp(fan, "2") == 0 || strcmp(fan, "3") == 0 ||
      strcmp(fan, "4") == 0 || strcmp(fan, "5") == 0) {
    return atof(fan);
  }
  // NOTE: HomeKit `RotationSpeed` characteristic only supports
  // discrete values. For all other values, we set it a nominal value of 3.
  return 3.f;
}

float homeKitTargetTempCoolToHeatPumpTemp(float targetTempCool) {
  // NOTE: We limit the temperature range to 16-31 Celsius.
  if (targetTempCool < 16) {
    return 16;
  }
  if (targetTempCool > 31) {
    return 31;
  }
  return targetTempCool;
}
float heatPumpTempToHomeKitTargetTempCool(float temp) {
  // NOTE: We limit the temperature range to 16-31 Celsius.
  if (temp < 16) {
    return 16;
  }
  if (temp > 31) {
    return 31;
  }
  return temp;
}
