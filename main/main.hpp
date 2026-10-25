#ifndef MAIN_HPP
#define MAIN_HPP

#include <Arduino.h>
#include <HeatPump.h>
#include <Matter.h>

#include "LED.hpp"

void checkMatterConnection();
void handleMatterDecommission();

bool modeChangeCallback(MatterThermostat::ThermostatMode_t mode);
bool coolingSetpointChangeCallback(double setpoint);

void hpSettingsChanged();
void hpStatusChanged(heatpumpStatus status);

#endif // MAIN_HPP
