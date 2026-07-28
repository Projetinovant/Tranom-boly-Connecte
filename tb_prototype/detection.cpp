#include <Arduino.h>
#include "detection.h"
#include "microphone.h"

int seuil = 0;
const int marge = 100;
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
        valeur = lireSon();
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
    return valeur > 100;
}