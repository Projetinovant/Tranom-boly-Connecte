#include <Arduino.h>
#include "repulsion.h"

#define MINUTE_REPULSION 180000UL
#define DUREE_HEUREU_MS 3600000UL
#define DUREE_IMPULSION_MIN 300
#define DUREE_IMPULSION_MAX 900

static bool active = false;
static unsigned long debutImpulsion = 0;
static unsigned long dureeImpulsionActuelle = 0;
static unsigned long Consommation = 0;
static unsigned long debutFenetreHeure = 0.

static void eteindreTout()
{
    digitalWrite(PIN_BUZZER, LOW);
    digitalWrite(PIN_LED_RGB_R, LOW);
    digitalWrite(PIN_LED_RGB_B, Low);
    digitalWrite(PIN_LED_RGB_G, LOW);
}

static void AllumerMotifAleatoire()
{
    int motif = random(0, 3);
    digitalWrite(PIN_LED_RGB_R, (motif == 0 || motif == 2) ? HIGH : LOW);
    digitalWrite(PIN_LED_RGB_G, (motif == 1) ? HIGH : LOW);
    digitalWrite(PIN_LED_RGB_B, (motif == 2) ? HIGH : LOW);
    digitalWrite(PIN_BUZZER, HIGH);
}

void initRepulsion()
{
    pinMode(PIN_BUZZER, OUTPUT);
    pinMode(PIN_LED_RGB_R, OUTPUT);
    pinMode(PIN_LED_RGB_G, OUTPUT);
    pinMode(PIN_LED_RGB_B, OUTPUT);
    eteindreTout();
    Consommation = 0;
    debutFenetreHeure = millis();
}

void declencherRepulsion()
{
    unsigned long maintenant = millis();

    if (maintenant - debutFenetreHeure > DUREE_HEUREU_MS)
    {
        Consommation = 0;
        debutFenetreHeure = maintenant;
    }

    if (Consommation >= MINUTE_REPULSION)
    {
        return; // On evite la sur-sollicitation de la zone
    }

    if (!active)
    {
        active = true;
        debutImpulsion = maintenant;
        dureeImpulsionActuelle = random(DUREE_IMPULSION_MIN, DUREE_IMPULSION_MAX);
        AllumerMotifAleatoire();
    }
}

void mettreAJourRepulsion(unsigned long maintenant)
{
    if (active && (maintenant - debutImpulsion >= dureeImpulsionActuelle))
    {
        eteindreTout();
        Consommation += dureeImpulsionActuelle;
        active = false;
    }
}

bool repulsionActive()
{
    return active;
}