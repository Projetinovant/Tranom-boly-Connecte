#include <Arduino.h>
#include "detection.h"
#include "microphone.h"
#include "DHT.h"

#define DHTPIN 4
#define DHTTYPE DHT22
#define SOL_PIN 34
#define RELAIS_EAU 26
#define RELAIS_ENGRAIS 27

int seuil = 0;
const int marge = 0;

DHT dht(DHTPIN, DHTTYPE);
void initCapteurs()
{
  dht.begin();

  pinMode(RELAIS_EAU, OUTPUT);
  pinMode(RELAIS_ENGRAIS, OUTPUT);

  digitalWrite(RELAIS_EAU, HIGH);
  digitalWrite(RELAIS_ENGRAIS, HIGH);
  
}
void calibrer()
{
    int i;
    int valeur;
    int maximum;
    maximum = 0;
    Serial.println("Calibration...");
    Serial.println("Pas de bruit");

    for(i = 0; i < 100; i++)
    {
        valeur = lireAmplitude();
        if(valeur > maximum)
        {
            maximum = valeur;
        }
        delay(10);
    }
    seuil = maximum + marge;
    Serial.print("Nouveau seuil : ");
    Serial.println(seuil);
}

bool sonDetecte(int valeur)
{
    return valeur > seuil;
}

float temperature()
{
  float t;
  t = dht.readTemperature();
  if(isnan(t))
  {
    return -1;
  }
  return t;
}

float humidite()
{
  return analogRead(SOL_PIN);
}
void arrosage()
{
  float h;
  h = humidite();
  if(h > 2500)
  {
    Serial.println("Sol sec");
    digitalWrite(RELAIS_EAU, LOW);
    delay(5000);
    digitalWrite(RELAIS_EAU, HIGH);
    Serial.println("Arrosage termine");
  }
  
}
void ajoutEngrais()
{
  float t;
  float h;
  if(t > 28 && h < 1800)
  {
    Serial.println("Ajout d'engrais");
    digitalWrite(RELAIS_ENGRAIS, LOW);
    delay(5000);
    digitalWrite(RELAIS_ENGRAIS, HIGH);
    Serial.println("Fin ajout d'engrais");
  }
}
