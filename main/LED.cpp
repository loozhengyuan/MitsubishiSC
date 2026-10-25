#include "LED.hpp"

// Default timings for blink (ms)
constexpr uint32_t DEFAULT_ON = 100;
constexpr uint32_t DEFAULT_OFF = 100;

LED::LED(uint8_t pin, bool activeHigh)
    : _pin(pin), _activeHigh(activeHigh), _state(false), _blinking(false),
      _onInterval(DEFAULT_ON), _offInterval(DEFAULT_OFF), _remainingBlinks(0),
      _previousMillis(0) {}

void LED::begin() {
  pinMode(_pin, OUTPUT);
  off();
}

void LED::on() {
  _blinking = false;
  _state = true;
  write(true);
}

void LED::off() {
  _blinking = false;
  _state = false;
  write(false);
}

void LED::toggle() {
  _blinking = false;
  _state = !_state;
  write(_state);
}

void LED::blink() {
  blink(0, DEFAULT_ON, DEFAULT_OFF); // 0 = infinite
}

void LED::blink(uint16_t count) { blink(count, DEFAULT_ON, DEFAULT_OFF); }

void LED::blink(uint16_t count, uint32_t interval) {
  blink(count, interval, interval);
}

void LED::blink(uint16_t count, uint32_t on, uint32_t off) {
  _blinking = true;
  _onInterval = on;
  _offInterval = off;
  _remainingBlinks = count; // 0 = infinite
  _previousMillis = millis();

  _state = true;
  write(true);
}

void LED::stop() {
  _blinking = false;
  _state = false;
  write(false);
}

void LED::update() {
  if (!_blinking)
    return;

  uint32_t currentMillis = millis();
  uint32_t interval = _state ? _onInterval : _offInterval;

  if (currentMillis - _previousMillis >= interval) {
    _previousMillis = currentMillis;
    _state = !_state;
    write(_state);

    // Only decrement when LED turns off (completed an ON cycle)
    if (!_state && _remainingBlinks > 0) {
      _remainingBlinks--;
      if (_remainingBlinks == 0) {
        _blinking = false;
        _state = false;
        write(false);
      }
    }
  }
}

bool LED::isOn() const { return _state; }

bool LED::isBlinking() const { return _blinking; }

void LED::write(bool state) {
  digitalWrite(_pin, _activeHigh ? (state ? HIGH : LOW) : (state ? LOW : HIGH));
}
