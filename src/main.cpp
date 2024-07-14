#include <Arduino.h>
#include <ArduinoJson.h>
#include <HeatPump.h>
#include <PubSubClient.h>
#include <WiFi.h>

#ifndef WIFI_SSID
#define WIFI_SSID ""
#endif
#ifndef WIFI_PASS
#define WIFI_PASS ""
#endif

#define AC_RX A0
#define AC_TX A1

#define AC_MQTT_TOPIC_TIMERS "aircon/timers"
#define AC_MQTT_TOPIC_SETTINGS "aircon/settings"
#define AC_MQTT_TOPIC_STATUS "aircon/status"
#define AC_MQTT_TOPIC_DEBUG "aircon/debug"

WiFiClient wifi;
PubSubClient pubSub;
HeatPump hp;


void hpSettingsChanged() {
  const size_t bufferSize = JSON_OBJECT_SIZE(6);
  DynamicJsonDocument root(bufferSize);

  heatpumpSettings currentSettings = hp.getSettings();

  root["power"] = currentSettings.power;
  root["mode"] = currentSettings.mode;
  root["temperature"] = currentSettings.temperature;
  root["fan"] = currentSettings.fan;
  root["vane"] = currentSettings.vane;
  root["wideVane"] = currentSettings.wideVane;
  // root["iSee"]        = currentSettings.iSee;

  char buffer[512];
  serializeJson(root, buffer);

  bool retain = true;
  if (!pubSub.publish(AC_MQTT_TOPIC_SETTINGS, buffer, retain)) {
    pubSub.publish(AC_MQTT_TOPIC_DEBUG, "failed to publish to heatpump topic");
  }
}

void hpStatusChanged(heatpumpStatus currentStatus) {
  // send room temp and operating info
  const size_t bufferSizeInfo = JSON_OBJECT_SIZE(2);
  DynamicJsonDocument rootInfo(bufferSizeInfo);

  rootInfo["roomTemperature"] = currentStatus.roomTemperature;
  rootInfo["operating"] = currentStatus.operating;

  char bufferInfo[512];
  serializeJson(rootInfo, bufferInfo);

  if (!pubSub.publish(AC_MQTT_TOPIC_STATUS, bufferInfo, true)) {
    pubSub.publish(AC_MQTT_TOPIC_DEBUG,
                   "failed to publish to room temp and operation status to "
                   "heatpump/status topic");
  }

  // send the timer info
  const size_t bufferSizeTimers = JSON_OBJECT_SIZE(5);
  DynamicJsonDocument rootTimers(bufferSizeTimers);

  rootTimers["mode"] = currentStatus.timers.mode;
  rootTimers["onMins"] = currentStatus.timers.onMinutesSet;
  rootTimers["onRemainMins"] = currentStatus.timers.onMinutesRemaining;
  rootTimers["offMins"] = currentStatus.timers.offMinutesSet;
  rootTimers["offRemainMins"] = currentStatus.timers.offMinutesRemaining;

  char bufferTimers[512];
  serializeJson(rootTimers, bufferTimers);

  if (!pubSub.publish(AC_MQTT_TOPIC_TIMERS, bufferTimers, true)) {
    pubSub.publish(AC_MQTT_TOPIC_DEBUG,
                   "failed to publish timer info to heatpump/status topic");
  }
}

void hpPacketDebug(byte *packet, unsigned int length, char *packetDirection) {
  String message;
  for (int idx = 0; idx < length; idx++) {
    if (packet[idx] < 16) {
      message += "0"; // pad single hex digits with a 0
    }
    message += String(packet[idx], HEX) + " ";
  }

  const size_t bufferSize = JSON_OBJECT_SIZE(6);
  DynamicJsonDocument root(bufferSize);

  root[packetDirection] = message;

  char buffer[512];
  serializeJson(root, buffer);

  if (!pubSub.publish(AC_MQTT_TOPIC_DEBUG, buffer)) {
    pubSub.publish(AC_MQTT_TOPIC_DEBUG,
                   "failed to publish to heatpump/debug topic");
  }
}

void setup() {
  Serial.begin(9600);

  pinMode(RGB_BUILTIN, OUTPUT);

  // Set up WiFi
  Serial.println("Setting up WiFi");
  WiFi.hostname("MitsubishiSC");
  WiFi.mode(WIFI_STA);
  WiFi.begin(WIFI_SSID, WIFI_PASS);
  while (WiFi.status() != WL_CONNECTED) {
    Serial.println("Connecting to WiFi..");
    delay(1000);
    neopixelWrite(RGB_BUILTIN, 1, 1, 1);
    delay(500);
    neopixelWrite(RGB_BUILTIN, 0, 0, 0);
  }

  // Set up MQTT connection
  Serial.println("Setting up MQTT");
  pubSub.setClient(wifi);
  pubSub.setServer("127.0.0.1", 1883); // TODO: Set this to the corresponding MQTT server
  while (!pubSub.connected()) {
    Serial.println("Connecting to PubSub..");
    pubSub.connect("ESP32");
    delay(1000);
    neopixelWrite(RGB_BUILTIN, 1, 1, 1);
    delay(500);
    neopixelWrite(RGB_BUILTIN, 0, 0, 0);
  }

  // connect to the heatpump. Callbacks first so that the hpPacketDebug callback
  // is available for connect()
  hp.setSettingsChangedCallback(hpSettingsChanged);
  hp.setStatusChangedCallback(hpStatusChanged);
  hp.setPacketCallback(hpPacketDebug);
  // Set up CN105 connection
  hp.connect(&Serial1);

  Serial.println("Set up completed!");
}

void loop() {
  // TODO: Add WiFi/MQTT reconnect logic

  hp.sync();
}
