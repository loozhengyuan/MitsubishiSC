#include "HomeKitAirConditioner.hpp"

HomeKitAirConditioner::HomeKitAirConditioner() : Service::HeaterCooler() {
  Serial.printf("\n*** Creating Mitsubishi Air Conditioner ***\n");

  // Restrict to COOL mode only
  currentState.setValidValues(1, 3);
  targetState.setValidValues(1, 2);

  // Restrict to Fan Speed 1-4 (0 denotes OFF state)
  fanSpeed.setRange(0, 4);

  // Restrict temperature values to 16-31 Celsius (w/ 1 degree increments)
  targetTempCool.setRange(16, 31, 1);
};

boolean HomeKitAirConditioner::update() {
  if (active.updated()) {
    Serial.printf("Power updated to %s\n", active.getNewVal() ? "ON" : "OFF");
    if (handleStateUpdate) {
      handleStateUpdate(active.getNewVal() == 1);
    };
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
    if (handleModeUpdate) {
      handleModeUpdate(targetState.getNewVal());
    };
  }
  if (oscillation.updated()) {
    Serial.printf("Oscillation set to %s\n",
                  oscillation.getNewVal() ? "ON" : "OFF");
    if (handleOscillationUpdate) {
      handleOscillationUpdate(oscillation.getNewVal() == 1);
    };
  }
  if (fanSpeed.updated()) {
    Serial.printf("Fan Speed set to %g\n", fanSpeed.getNewVal<float>());
    if (handleFanSpeedUpdate) {
      handleFanSpeedUpdate(fanSpeed.getNewVal<float>());
    };
  }
  if (targetTempCool.updated()) {
    Serial.printf("Temperature set to %g\n", targetTempCool.getNewVal<float>());
    if (handleTempCoolUpdate) {
      handleTempCoolUpdate(targetTempCool.getNewVal<float>());
    };
  }
  return (true);
}

// TODO: Verify that it does not loop endlessly?
void HomeKitAirConditioner::setCurrentTemp(float temp) {
  if (this->currentTemp.getVal<float>() != temp &&
      this->currentTemp.timeVal() > updateDelayMs) {
    this->currentTemp.setVal(temp);
  }
}
void HomeKitAirConditioner::setCurrentState(bool state) {
  if (this->active.getVal() != state &&
      this->active.timeVal() > updateDelayMs) {
    this->active.setVal(state);
  }
}
void HomeKitAirConditioner::setCurrentMode(int mode) {
  if (this->targetState.getVal() != mode &&
      this->targetState.timeVal() > updateDelayMs) {
    this->targetState.setVal(mode);
  }
}
void HomeKitAirConditioner::setCurrentOscillation(bool oscillation) {
  if (this->oscillation.getVal() != oscillation &&
      this->oscillation.timeVal() > updateDelayMs) {
    this->oscillation.setVal(oscillation);
  }
}
void HomeKitAirConditioner::setCurrentFanSpeed(float fanSpeed) {
  if (this->fanSpeed.getVal<float>() != fanSpeed &&
      this->fanSpeed.timeVal() > updateDelayMs) {
    this->fanSpeed.setVal(fanSpeed);
  }
}
void HomeKitAirConditioner::setCurrentTempCool(float temp) {
  if (this->targetTempCool.getVal<float>() != temp &&
      this->targetTempCool.timeVal() > updateDelayMs) {
    this->targetTempCool.setVal(temp);
  }
}

void HomeKitAirConditioner::setStateUpdateCallback(
    std::function<void(bool state)> callback) {
  handleStateUpdate = callback;
}
void HomeKitAirConditioner::setModeUpdateCallback(
    std::function<void(int mode)> callback) {
  handleModeUpdate = callback;
}
void HomeKitAirConditioner::setOscillationUpdateCallback(
    std::function<void(bool oscillation)> callback) {
  handleOscillationUpdate = callback;
}
void HomeKitAirConditioner::setFanSpeedUpdateCallback(
    std::function<void(float fanSpeed)> callback) {
  handleFanSpeedUpdate = callback;
}
void HomeKitAirConditioner::setTempCoolUpdateCallback(
    std::function<void(float targetTempCool)> callback) {
  handleTempCoolUpdate = callback;
}
