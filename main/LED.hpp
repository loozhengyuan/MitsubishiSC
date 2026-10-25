#ifndef LED_HPP
#define LED_HPP

#include <Arduino.h>

class LED {
public:
  explicit LED(uint8_t pin, bool activeHigh = true);

  void begin();

  void on();
  void off();
  void toggle();

  void blink();
  void blink(uint16_t count);
  void blink(uint16_t count, uint32_t interval);
  void blink(uint16_t count, uint32_t on, uint32_t off);

  void stop();

  void update();

  bool isOn() const;
  bool isBlinking() const;

private:
  void write(bool state);

  uint8_t _pin;
  bool _activeHigh;

  bool _state;
  bool _blinking;

  uint32_t _onInterval;
  uint32_t _offInterval;
  uint16_t _remainingBlinks;
  uint32_t _previousMillis;
};

#endif // LED_HPP
