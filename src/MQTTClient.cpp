#include "MQTTClient.hpp"

MQTTClient::MQTTClient(const char* clientId) {
  this->client = new PubSubClient();
  this->client->setServer(MQTT_HOST, MQTT_PORT);
  this->clientId = clientId;
  this->lastConnectionAttempt = 0;
  this->connectionDelay = 1000;  // 1 second
}

PubSubClient* MQTTClient::getClient() {
  return client;
}

void MQTTClient::setWiFiClient(WiFiClient& wifiClient) {
  client->setClient(wifiClient);
}

bool MQTTClient::isConnected() {
  return client->connected();
}

bool MQTTClient::publish(const char* topic, const char* payload) {
  return client->publish(topic, payload);
}

void MQTTClient::tryConnect() {
  uint32_t attemptElapsed = millis() - lastConnectionAttempt;
  if (!client->connected() && attemptElapsed > connectionDelay) {
    Serial.println("Attempting to connect to MQTT server..");
    lastConnectionAttempt = millis();

    // TODO: Add logic to blink LEDs during connection attempt?
    if (client->connect(clientId)) {
      Serial.println("Connected to MQTT server!");
      connectionDelay = 1000;
      return;
    }

    // Exponentially increase connection delay until 10 minutes max.
    uint32_t next = connectionDelay * 2;
    if (next < 10 * 60 * 1000) {
      Serial.printf("Retrying in %d seconds\n", next / 1000);
      connectionDelay = next;
    }
  }
}