#include "HomeSpan.h"

// NOTE: The `HeaterCooler` device type is primarily chosen because of the
// ability to set the fan speed/oscillation mode.
// https://github.com/HomeSpan/HomeSpan/blob/master/docs/ServiceList.md#heatercooler-bc
// https://github.com/HomeSpan/HomeSpan/blob/master/docs/ServiceList.md#thermostat-4a
struct MitsubishiAirConditioner : Service::HeaterCooler {
  // Required Characteristics
  Characteristic::Active active{0, true};
  Characteristic::CurrentTemperature currentTemp{24, true};
  Characteristic::CurrentHeaterCoolerState currentState{3, true};
  Characteristic::TargetHeaterCoolerState targetState{2, true};

  // Optional Characteristics
  Characteristic::RotationSpeed fanSpeed{3, true};
  Characteristic::TemperatureDisplayUnits tempUnits{0, true};
  Characteristic::SwingMode oscillation{0, true};
  Characteristic::CoolingThresholdTemperature targetTempCool{24, true};
  // Characteristic::HeatingThresholdTemperature targetTempHeat{24, true};
  // Characteristic::LockPhysicalControls childLock{0, true};

  MitsubishiAirConditioner() : Service::HeaterCooler() {
    Serial.printf("\n*** Creating Mitsubishi Air Conditioner ***\n");

    // Restrict to COOL mode only
    currentState.setValidValues(1, 3);
    targetState.setValidValues(1, 2);

    // Restrict to Fan Speed 1-4 (0 denotes OFF state)
    fanSpeed.setRange(0, 4);

    // Restrict temperature values to 16-31 Celsius (w/ 1 degree increments)
    targetTempCool.setRange(16, 31, 1);
  }

  boolean update() override {
    if (active.updated()) {
      Serial.printf("Power set to %s\n", active.getNewVal() ? "ON" : "OFF");
      // TODO: Update power state via UART
    }
    if (targetState.updated()) {
      switch (targetState.getNewVal()) {
      case 0:
        Serial.printf("Mode set to AUTO\n");
        break;
      case 1:
        Serial.printf("Mode set to HEAT\n");
        break;
      case 2:
        Serial.printf("Mode set to COOL\n");
        break;
      }
      Serial.printf("WARNING: Mode changes are not implemented\n");
    }
    if (oscillation.updated()) {
      Serial.printf("Oscillation set to %s\n",
                    oscillation.getNewVal() ? "ON" : "OFF");
      // TODO: Set swing mode via UART
    }
    if (fanSpeed.updated()) {
      Serial.printf("Fan Speed set to %g\n", fanSpeed.getNewVal<float>());
      // TODO: Set fan speed via UART
    }
    if (targetTempCool.updated()) {
      Serial.printf("Temperature set to %g\n",
                    targetTempCool.getNewVal<float>());
      // TODO: Set cooling threshold temperature via UART
    }
    return (true);
  }
  // TODO: Update state based on callback from Mitsubishi Air Conditioner.
};

void setup() {
  Serial.begin(115200);

  homeSpan.setStatusPin(LED_BUILTIN);
  homeSpan.setControlPin(9);
  homeSpan.begin(Category::AirConditioners,
                 "Air Conditioner"); // TODO: Must be unique?

  new SpanAccessory();
  new Service::AccessoryInformation();
  new Characteristic::Identify();
  new Characteristic::Name("Air Conditioner");
  new Characteristic::Manufacturer("Mitsubishi Electric");
  new Characteristic::Model("MSXY-FP Series");
  new Characteristic::FirmwareRevision("0.1.0");

  new MitsubishiAirConditioner();
}

void loop() { homeSpan.poll(); }
