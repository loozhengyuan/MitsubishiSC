#ifndef HOMEKIT_AIR_CONDITIONER_HPP
#define HOMEKIT_AIR_CONDITIONER_HPP

#include <HomeSpan.h>

class HomeKitAirConditioner : public Service::HeaterCooler {
 public:
  HomeKitAirConditioner();

  boolean update() override;

  void setCurrentTemp(float temp);
  void setCurrentState(bool state);
  void setCurrentMode(int mode);
  void setCurrentOscillation(bool oscillation);
  void setCurrentFanSpeed(float fanSpeed);
  void setCurrentTempCool(float targetTempCool);

  void setStateUpdateCallback(std::function<void(bool state)> callback);
  void setModeUpdateCallback(std::function<void(int mode)> callback);
  void setOscillationUpdateCallback(
      std::function<void(bool oscillation)> callback);
  void setFanSpeedUpdateCallback(std::function<void(float fanSpeed)> callback);
  void setTempCoolUpdateCallback(
      std::function<void(float targetTempCool)> callback);

 private:
  // Delay in milliseconds between updates. Mitigates impact of infinite loops.
  uint32_t updateDelayMs = 3 * 1000;

  std::function<void(bool state)> handleStateUpdate;
  std::function<void(int mode)> handleModeUpdate;
  std::function<void(bool oscillation)> handleOscillationUpdate;
  std::function<void(float fanSpeed)> handleFanSpeedUpdate;
  std::function<void(float targetTempCool)> handleTempCoolUpdate;

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
};

#endif  // HOMEKIT_AIR_CONDITIONER_HPP