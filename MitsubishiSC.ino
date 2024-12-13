#include <Matter.h>
#include <MatterLightbulb.h>

MatterLightbulb light1;

void setup()
{
  Serial.begin(115200);

  Matter.begin();
  light1.begin();

  // Matter.decommission();

  pinMode(LED_BUILTIN, OUTPUT);
  digitalWrite(LED_BUILTIN, LED_BUILTIN_INACTIVE);

  light1.set_vendor_name("Seeed Studio");
  light1.set_product_name("XIAO MG24");
  light1.set_serial_number(getDeviceUniqueIdStr().c_str());
  light1.set_device_name("On/Off Switch");

  if (!Matter.isDeviceCommissioned())
  {
    Serial.println("Matter device is not commissioned");
    Serial.println("Commission it to your Matter hub with the manual pairing code or QR code");
    Serial.printf("Manual pairing code: %s\n", Matter.getManualPairingCode().c_str());
    Serial.printf("QR code URL: %s\n", Matter.getOnboardingQRCodeUrl().c_str());
  }
  while (!Matter.isDeviceCommissioned())
  {
    digitalWrite(LED_BUILTIN, LED_BUILTIN_ACTIVE);
    delay(100);
    digitalWrite(LED_BUILTIN, LED_BUILTIN_INACTIVE);
    delay(1000);
  }

  Serial.println("Waiting for Thread network...");
  while (!Matter.isDeviceThreadConnected())
  {
    digitalWrite(LED_BUILTIN, LED_BUILTIN_ACTIVE);
    delay(100);
    digitalWrite(LED_BUILTIN, LED_BUILTIN_INACTIVE);
    delay(100);
    digitalWrite(LED_BUILTIN, LED_BUILTIN_ACTIVE);
    delay(100);
    digitalWrite(LED_BUILTIN, LED_BUILTIN_INACTIVE);
    delay(1000);
  }
  Serial.println("Connected to Thread network");

  Serial.println("Waiting for Matter device discovery...");
  while (!light1.is_online())
  {
    digitalWrite(LED_BUILTIN, LED_BUILTIN_ACTIVE);
    delay(100);
    digitalWrite(LED_BUILTIN, LED_BUILTIN_INACTIVE);
    delay(100);
    digitalWrite(LED_BUILTIN, LED_BUILTIN_ACTIVE);
    delay(100);
    digitalWrite(LED_BUILTIN, LED_BUILTIN_INACTIVE);
    delay(100);
    digitalWrite(LED_BUILTIN, LED_BUILTIN_ACTIVE);
    delay(100);
    digitalWrite(LED_BUILTIN, LED_BUILTIN_INACTIVE);
    delay(1000);
  }
  Serial.println("Matter device is now online");
}

void loop()
{
  bool light1_current = digitalRead(LED_BUILTIN) == LED_BUILTIN_ACTIVE;
  bool light1_desired = light1.get_onoff();

  if (light1_desired && !light1_current)
  {
    digitalWrite(LED_BUILTIN, LED_BUILTIN_ACTIVE);
    Serial.println("LED ON");
  }
  if (!light1_desired && light1_current)
  {
    digitalWrite(LED_BUILTIN, LED_BUILTIN_INACTIVE);
    Serial.println("LED OFF");
  }
}
