#include <Arduino.h>
#include "microphone.h"
#define MIC_PIN 34

//const int VALEUR_REPOS = 2048;
void initMicrophone()
{
    // Serial.begin();
    pinMode(MIC_PIN, INPUT);
}

int lireSon()
{
    return analogRead(MIC_PIN);;
}
int lireAmplitude()
{
    return lireSon();
}
