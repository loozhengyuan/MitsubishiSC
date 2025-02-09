#include <Arduino.h>
#include <WiFi.h>

#include <ArduinoJson.h>
#include <HeatPump.h>
#include <PubSubClient.h>

#include "AirConditioningController.hpp"
#include "HomeKitAirConditioner.hpp"

#ifndef WIFI_SSID
#define WIFI_SSID ""
#endif
#ifndef WIFI_PASS
#define WIFI_PASS ""
#endif

#ifdef MITSUBISHISC_V1
#define USER_LED 10
#else
#define USER_LED LED_BUILTIN
#endif

#define USER_BTN 9

#define CONN_RXD 0
#define CONN_TXD 1

char deviceId[30];

WiFiClient wifi;
HeatPump hp;
AirConditioningController
    ctrl(deviceId, &wifi, &hp, CONN_RXD, CONN_TXD, USER_LED, USER_BTN);

void setup() {
  Serial.begin(115200);

  delay(1000);  // Give time for serial monitor to initialize
  Serial.printf("Reset reason: %d\n", esp_reset_reason());

  pinMode(USER_LED, OUTPUT);

  // Derive device identifier
  snprintf(deviceId, sizeof(deviceId), "mitsubishisc-%016llx",
           ESP.getEfuseMac());
  Serial.printf("Device ID: %s\n", deviceId);

  // Set up WiFi
  Serial.println("Setting up WiFi");
  WiFi.hostname(deviceId);
  WiFi.mode(WIFI_STA);
  WiFi.setTxPower(WIFI_POWER_2dBm);  // NOTE: No need to go full power
  WiFi.setAutoReconnect(true);
  WiFi.begin(WIFI_SSID, WIFI_PASS);
  while (WiFi.status() != WL_CONNECTED) {
    Serial.printf("Connecting to WiFi: %d\n", WiFi.status());
    delay(1000);
    digitalWrite(USER_LED, HIGH);
    delay(500);
    digitalWrite(USER_LED, LOW);
  }

  // Set up controller
  ctrl.setup();
  Serial.println("Set up completed!");
}

void loop() {
  ctrl.loop();
}
