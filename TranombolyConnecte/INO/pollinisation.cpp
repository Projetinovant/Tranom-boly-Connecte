#include <Arduino.h>
#include "pollinisation.h"
#include "config.h"

static bool active = false;
static unsigned long debut = 0;
static unsigned long duree = 0;
static unsigned long dernierePollinisationPeriodique = 0;

#define INTERVALLE_POLLINISATION_PERIODIQUE_MS 1800000UL // 30 min : filet de securite
#define SEUIL_LUMINOSITE_JOUR                   1500      // a calibrer selon la photoresistance utilisee

void initPollinisation()
{
    pinMode(PIN_VIBREUR, OUTPUT);
    digitalWrite(PIN_VIBREUR, LOW);
    dernierePollinisationPeriodique = millis();
}

void declencherPollinisation(unsigned long dureeMs)
{
    if(!active)
    {
        active = true;
        debut = millis();
        duree = dureeMs;
        digitalWrite(PIN_VIBREUR, HIGH);
    }
}

void mettreAJourPollinisation(unsigned long maintenant)
{
    if(active && (maintenant - debut >= duree))
    {
        digitalWrite(PIN_VIBREUR, LOW);
        active = false;
    }
}

void verifierPollinisationPeriodique(unsigned long maintenant, float luminosite)
{
    // Filet de securite : meme sans visite de pollinisateur detectee, on
    // sollicite periodiquement les fleurs pendant la journee (technique
    // horticole reelle, voir dossier section 3.4), pour ne pas dependre
    // uniquement de la detection acoustique.
    if(luminosite > SEUIL_LUMINOSITE_JOUR && (maintenant - dernierePollinisationPeriodique) > INTERVALLE_POLLINISATION_PERIODIQUE_MS)
    {
        declencherPollinisation(1500);
        dernierePollinisationPeriodique = maintenant;
    }
}

bool pollinisationActive()
{
    return active;
}
