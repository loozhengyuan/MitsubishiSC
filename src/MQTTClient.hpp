#ifndef MQTT_CLIENT_HPP
#define MQTT_CLIENT_HPP

#ifndef MQTT_HOST
#define MQTT_HOST "127.0.0.1"
#endif
#ifndef MQTT_PORT
#define MQTT_PORT 1883
#endif

#include <string>

#include <PubSubClient.h>
#include <WiFi.h>

class MQTTClient {
 public:
  MQTTClient(const char* clientId);

  PubSubClient* getClient();

  void setWiFiClient(WiFiClient& wifiClient);

  /** Returns true if the client is connected to the MQTT server. */
  bool isConnected();

  /**
   * Attempts to connect to the MQTT server.
   *
   * If the connection was not successful, it will only exponentially
   * increase the delay between connection attempts.
   * */
  void tryConnect();

  bool publish(const char* topic, const char* payload);

 private:
  PubSubClient* client;
  const char* clientId;

  /** Represents the last time a connection attempt was made. */
  uint32_t lastConnectionAttempt;

  /** Controls the delay between connection attempts. */
  uint32_t connectionDelay;
};

#endif  // MQTT_CLIENT_HPP
