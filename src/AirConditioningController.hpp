#ifndef AIR_CONDITIONING_CONTROLLER_HPP
#define AIR_CONDITIONING_CONTROLLER_HPP

#include <string>

#include <HeatPump.h>
#include <PubSubClient.h>
#include <WiFi.h>

#include "HomeKitAirConditioner.hpp"
#include "MQTTClient.hpp"

class AirConditioningController {
 public:
  AirConditioningController(char* deviceId,
                            WiFiClient* wifi,
                            HeatPump* hp,
                            uint8_t rxPin,
                            uint8_t txPin,
                            uint8_t userLedPin,
                            uint8_t userBtnPin);
  ~AirConditioningController();

  void setup();
  void loop();

 private:
  char* deviceId;

  uint8_t rxPin;
  uint8_t txPin;
  uint8_t userLedPin;
  uint8_t userBtnPin;

  MQTTClient* mqtt;
  HeatPump* hp;
  HomeKitAirConditioner* hk;

  uint32_t lastDebugPublished = 0;

  char* pubSubTopicSettings;
  char* pubSubTopicStatus;
  char* pubSubTopicTimers;
  char* pubSubTopicDebug;

  void publish(const char* topic, const char* payload);
  void publishSettings(heatpumpSettings current);
  void publishStatus(heatpumpStatus current);
  void publishTimers(heatpumpTimers current);
  void publishPacket(byte* packet, unsigned int length, char* packetDirection);

  void handleSettingsChanged();
  void handleStatusChanged(heatpumpStatus newStatus);
  void handlePacketReceived(byte* packet,
                            unsigned int length,
                            char* packetDirection);

  void handleHeatPumpRoomTemperatureUpdated(float roomTemperature);

  void handleHeatPumpPowerUpdated(const char* power);
  void handleHeatPumpModeUpdated(const char* mode);
  void handleHeatPumpVaneUpdated(const char* vane);
  void handleHeatPumpFanUpdated(const char* fan);
  void handleHeatPumpTempUpdated(float temp);

  void handleHomeKitPowerUpdated(bool active);
  void handleHomeKitTargetStateUpdated(int targetState);
  void handleHomeKitSwingModeUpdated(bool swingMode);
  void handleHomeKitRotationSpeedUpdated(float rotationSpeed);
  void handleHomeKitTargetTempCoolUpdated(float targetTempCool);
};

bool heatPumpPowerToHomeKitActive(const char* power);
int heatPumpModetoHomeKitTargetState(const char* mode);
bool heatPumpVaneToHomeKitSwingMode(const char* vane);
float heatPumpFanToHomeKitRotationSpeed(const char* fan);
float heatPumpTempToHomeKitTargetTempCool(float temp);

const char* homeKitActiveToHeatPumpPower(bool active);
const char* homeKitTargetStateToHeatPumpMode(int targetState);
const char* homeKitSwingModeToHeatPumpVane(bool swingMode);
const char* homeKitRotationSpeedToHeatPumpFan(float rotationSpeed);
float homeKitTargetTempCoolToHeatPumpTemp(float targetTempCool);

#endif  // AIR_CONDITIONING_CONTROLLER_HPP
