#include <Arduino.h>
#include "acces.h"
#include "porte.h"
#include "config.h"

#define ANGLE_INSECTE_FERME  0
#define ANGLE_INSECTE_OUVERT 90

static Porte porteInsecte;

void initAcces()
{
    initPorte(porteInsecte, PIN_SERVO_PORTE_INSECTE, ANGLE_INSECTE_FERME, ANGLE_INSECTE_OUVERT);
    pinMode(PIN_LED_VERTE, OUTPUT);
    digitalWrite(PIN_LED_VERTE, LOW);
}

void ouvrirAcces()
{
    if(!porteEstOuverte(porteInsecte))
    {
        ouvrirPorte(porteInsecte);
        digitalWrite(PIN_LED_VERTE, HIGH); // indication locale : porte ouverte, pas de LCD
    }
}

void fermerAcces()
{
    if(porteEstOuverte(porteInsecte))
    {
        fermerPorte(porteInsecte);
        digitalWrite(PIN_LED_VERTE, LOW);
    }
}

bool accesEstOuvert()
{
    return porteEstOuverte(porteInsecte);
}
