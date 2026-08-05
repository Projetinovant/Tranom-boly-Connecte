#include "Led.hpp"
#include <Arduino.h>

Led::Led(int pin)
{
  numeroPin = pin;
  pinMode(numeroPin, OUTPUT);
}
Led::~Led()
{

}
void Led::allumer()
{
  digitalWrite(numeroPin,HIGH);
}
void Led::eteindre()
{
  digitalWrite(numeroPin,LOW);
}
