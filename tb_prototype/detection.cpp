#include <Arduino.h>
#include "detection.h"
#include "microphone.h"

int seuil = 0;
const int marge = 80;
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
