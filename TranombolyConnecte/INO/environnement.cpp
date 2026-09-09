#include <Arduino.h>
#include <DHT.h>
#include "environnement.h"
#include "config.h"

static DHT capteurDHT(PIN_DHT11, DHT11);
static DonneesEnvironnement derniereLecture = { 25.0f, 50.0f, 0, false };
static unsigned long derniereLectureDHT = 0;
#define INTERVALLE_LECTURE_DHT_MS 2500 // le DHT11 ne supporte pas des lectures plus frequentes que ~1s

void initEnvironnement()
{
    capteurDHT.begin();
    pinMode(PIN_PHOTORESISTANCE, INPUT);
}

DonneesEnvironnement lireEnvironnement()
{
    unsigned long maintenant = millis();

    if(maintenant - derniereLectureDHT >= INTERVALLE_LECTURE_DHT_MS)
    {
        float t = capteurDHT.readTemperature();
        float h = capteurDHT.readHumidity();

        if(!isnan(t) && !isnan(h))
        {
            derniereLecture.temperature = t;
            derniereLecture.humiditeAir = h;
            derniereLecture.lectureValide = true;
        }
        else
        {
            // Capteur non repondu : on garde la derniere valeur valide plutot
            // que de propager une valeur aberrante dans la classification
            derniereLecture.lectureValide = false;
        }
        derniereLectureDHT = maintenant;
    }

    derniereLecture.luminosite = analogRead(PIN_PHOTORESISTANCE);
    return derniereLecture;
}
