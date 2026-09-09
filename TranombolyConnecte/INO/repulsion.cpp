#include <Arduino.h>
#include "repulsion.h"
#include "config.h"

#define BUDGET_MAX_MS_PAR_HEURE   180000UL  // 3 min de repulsion active max par heure
#define DUREE_HEURE_MS            3600000UL
#define DUREE_IMPULSION_MIN_MS    300
#define DUREE_IMPULSION_MAX_MS    900

static bool active = false;
static unsigned long debutImpulsion = 0;
static unsigned long dureeImpulsionActuelle = 0;
static unsigned long budgetConsommeMs = 0;
static unsigned long debutFenetreHeure = 0;

static void eteindreTout()
{
    digitalWrite(PIN_BUZZER, LOW);
    digitalWrite(PIN_LED_RGB_R, LOW);
    digitalWrite(PIN_LED_RGB_G, LOW);
    digitalWrite(PIN_LED_RGB_B, LOW);
}

static void allumerMotifAleatoire()
{
    // Motif de couleur/duree randomise a chaque impulsion : limite
    // l'accoutumance des nuisibles a un signal toujours identique
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
    budgetConsommeMs = 0;
    debutFenetreHeure = millis();
}

void declencherRepulsion()
{
    unsigned long maintenant = millis();

    if(maintenant - debutFenetreHeure > DUREE_HEURE_MS)
    {
        budgetConsommeMs = 0;
        debutFenetreHeure = maintenant;
    }

    if(budgetConsommeMs >= BUDGET_MAX_MS_PAR_HEURE)
    {
        return; // budget epuise : on evite la sur-sollicitation de la zone
    }

    if(!active)
    {
        active = true;
        debutImpulsion = maintenant;
        dureeImpulsionActuelle = random(DUREE_IMPULSION_MIN_MS, DUREE_IMPULSION_MAX_MS);
        allumerMotifAleatoire();
    }
}

void mettreAJourRepulsion(unsigned long maintenant)
{
    if(active && (maintenant - debutImpulsion >= dureeImpulsionActuelle))
    {
        eteindreTout();
        budgetConsommeMs += dureeImpulsionActuelle;
        active = false;
    }
}

bool repulsionActive()
{
    return active;
}
