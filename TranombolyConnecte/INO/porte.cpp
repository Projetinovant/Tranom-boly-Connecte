#include <Arduino.h>
#include "porte.h"

static void deplacerPorte(Porte &porte, int angleFinal, int vitesseMs)
{
    int angle;

    if(angleFinal == porte.angleActuel)
    {
        return;
    }

    if(angleFinal > porte.angleActuel)
    {
        for(angle = porte.angleActuel; angle <= angleFinal; angle++)
        {
            porte.servo.write(angle);
            delay(vitesseMs);
        }
    }
    else
    {
        for(angle = porte.angleActuel; angle >= angleFinal; angle--)
        {
            porte.servo.write(angle);
            delay(vitesseMs);
        }
    }
    porte.angleActuel = angleFinal;
}

void initPorte(Porte &porte, int broche, int angleFerme, int angleOuvert)
{
    porte.broche = broche;
    porte.angleFerme = angleFerme;
    porte.angleOuvert = angleOuvert;
    porte.servo.attach(broche);
    porte.angleActuel = angleFerme;
    porte.servo.write(angleFerme);
    porte.ouverte = false;
}

void ouvrirPorte(Porte &porte, int vitesseMs)
{
    deplacerPorte(porte, porte.angleOuvert, vitesseMs);
    porte.ouverte = true;
}

void fermerPorte(Porte &porte, int vitesseMs)
{
    deplacerPorte(porte, porte.angleFerme, vitesseMs);
    porte.ouverte = false;
}

bool porteEstOuverte(const Porte &porte)
{
    return porte.ouverte;
}
