#include "main.hpp"

#include <platform/ESP32/ESP32FactoryDataProvider.h>

#define LED_BUILTIN 19
#define BUTTON_PIN 9

#define MATTER_DECOMMISSION_DELAY_MS 5000

LED statusLed(LED_BUILTIN);

HeatPump hp;
MatterThermostat device;

uint16_t discriminator = 0;

void setup() {
  // TODO: There are some issues enabling USB CDC though not attempted yet
  // https://github.com/espressif/arduino-esp32/issues/9363
  // Serial.begin(115200);

  pinMode(BUTTON_PIN, INPUT_PULLUP); // Boot pin button is active-low

  statusLed.begin();
  statusLed.off();

  hp.setFastSync(true);
  // NOTE: Configs set by IR remote should still remain
  hp.enableExternalUpdate();
  hp.setSettingsChangedCallback(hpSettingsChanged);
  hp.setStatusChangedCallback(hpStatusChanged);

  Serial1.begin(2400, SERIAL_8E1, 23, 22);
  hp.connect(&Serial1);

  // FIXME: There is outstanding bug with some control sequences
  // and we manually patch the libraries to make it work.
  // https://github.com/espressif/arduino-esp32/issues/12382
  device.begin(MatterThermostat::THERMOSTAT_SEQ_OP_COOLING,
               MatterThermostat::THERMOSTAT_AUTO_MODE_DISABLED);

  device.onChangeMode(modeChangeCallback);
  device.onChangeCoolingSetpoint(coolingSetpointChangeCallback);

  Matter.begin();

  CHIP_ERROR err =
      chip::DeviceLayer::ESP32FactoryDataProvider().GetSetupDiscriminator(
          discriminator);
  if (err != CHIP_NO_ERROR) {
    printf("Failed to get discriminator from factory data provider: %s\n",
           chip::ErrorStr(err));
  }
  printf("Discriminator: %u\n", discriminator);
}

void loop() {
  statusLed.update();

  handleMatterDecommission();
  checkMatterConnection();

  hp.sync();
}

void checkMatterConnection() {
  static unsigned long lastStatusTime = 0;

  const unsigned long now = millis();

  if (!Matter.isDeviceCommissioned() && now - lastStatusTime >= 3000) {
    printf("Pairing Code: %s\n", Matter.getManualPairingCode().c_str());
    printf("QR Code URL: %s\n", Matter.getOnboardingQRCodeUrl().c_str());
    printf("Waiting for commissioning...\n");
    statusLed.blink(1);
    lastStatusTime = now;
  }
  if (!Matter.isDeviceConnected() && now - lastStatusTime >= 3000) {
    printf("Waiting for WiFi/Thread network...\n");
    statusLed.blink(2);
    lastStatusTime = now;
  }
}

void handleMatterDecommission() {
  static unsigned long buttonPressedSince = 0;

  const bool isButtonPressed = digitalRead(BUTTON_PIN) == LOW;
  const unsigned long now = millis();

  // Return early if device is not commissioned
  if (!Matter.isDeviceCommissioned()) {
    return;
  }

  // Handle button state change events
  if (isButtonPressed && buttonPressedSince == 0) {
    printf("Detected user button: PRESSED\n");
    statusLed.on();
    buttonPressedSince = now;
    return;
  }
  if (!isButtonPressed && buttonPressedSince > 0) {
    printf("Detected user button: RELEASED\n");
    statusLed.off();
    buttonPressedSince = 0;
    return;
  }

  if (isButtonPressed &&
      now - buttonPressedSince >= MATTER_DECOMMISSION_DELAY_MS) {
    printf("Decommissioning Matter and resetting device to factory "
           "defaults...\n");
    Matter.decommission();
    buttonPressedSince = now; // Prevent double-call
  }
}

bool modeChangeCallback(MatterThermostat::ThermostatMode_t mode) {
  printf("Matter: Thermostat mode changed to %s\n",
         MatterThermostat::getThermostatModeString(mode));
  statusLed.blink(1);
  const char *power =
      mode == MatterThermostat::THERMOSTAT_MODE_OFF ? "OFF" : "ON";
  // Skip echoes of IR-initiated changes relayed back via hpSettingsChanged()
  if (strcmp(hp.getPowerSetting(), power) == 0) {
    return true;
  }
  hp.setPowerSetting(power);
  return true;
}

bool coolingSetpointChangeCallback(double setpoint) {
  printf("Matter: Cooling setpoint changed to %.1f°C\n", setpoint);
  statusLed.blink(1);
  // Skip echoes of IR-initiated changes relayed back via hpSettingsChanged()
  if (hp.getTemperature() == (float)setpoint) {
    return true;
  }
  hp.setTemperature(setpoint);
  return true;
}

void hpSettingsChanged() {
  heatpumpSettings current = hp.getSettings();
  printf("HeatPump Settings Changed: Power=%s, Mode=%s, Temp=%.1f°C, Fan=%s, "
         "Vane=%s, WideVane=%s\n",
         current.power, current.mode, current.temperature, current.fan,
         current.vane, current.wideVane);
  statusLed.blink(1);
  device.setMode(strcmp(current.power, "ON") == 0
                     ? MatterThermostat::THERMOSTAT_MODE_COOL
                     : MatterThermostat::THERMOSTAT_MODE_OFF);
  device.setCoolingSetpoint(current.temperature);
}

void hpStatusChanged(heatpumpStatus status) {
  printf("HeatPump Status Changed: RoomTemp=%.1f°C, Operating=%s, "
         "CompressorFreq=%d\n",
         status.roomTemperature, status.operating ? "YES" : "NO",
         status.compressorFrequency);
  statusLed.blink(1);
  device.setLocalTemperature(status.roomTemperature);
}
