#include <Arduino.h>
#include "sol.h"
#include "config.h"

// Valeurs brutes A CALIBRER avec la sonde reellement utilisee :
// lire la valeur a l'air libre (sec) puis plongee dans l'eau (humide)
#define ADC_SOL_SEC    2800
#define ADC_SOL_HUMIDE 1200

#define SEUIL_ARROSAGE_POURCENT   30
#define SEUIL_ARRET_POURCENT      55  // hysteresis : on arrose jusqu'a ce seuil, pas juste au-dessus du declenchement

void initSol()
{
    pinMode(PIN_HUMIDITE_SOL, INPUT);
}

int lireHumiditeSolPourcent()
{
    int brut = analogRead(PIN_HUMIDITE_SOL);
    brut = constrain(brut, ADC_SOL_HUMIDE, ADC_SOL_SEC);
    int pourcent = map(brut, ADC_SOL_SEC, ADC_SOL_HUMIDE, 0, 100);
    return pourcent;
}

bool solABesoinEau()
{
    static bool enCoursArrosage = false;
    int pourcent = lireHumiditeSolPourcent();

    if(!enCoursArrosage && pourcent < SEUIL_ARROSAGE_POURCENT)
    {
        enCoursArrosage = true;
    }
    else if(enCoursArrosage && pourcent >= SEUIL_ARRET_POURCENT)
    {
        enCoursArrosage = false;
    }
    return enCoursArrosage;
}
