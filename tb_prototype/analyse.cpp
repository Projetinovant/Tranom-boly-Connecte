#include <Arduino.h>
#include "analyse.h"
#include "microphone.h"

Caracteristiques analyserSon()
{
    Caracteristiques resultat;
    int i;
    int valeur;
    int somme;
    int maximum;
    int minimum;
    int ancienneValeur;
    int variation;
    int difference;
    int nombrePics;
    unsigned long debut;
    const int seuil_pic = 10;
    const int nombreMesures = 50;
    
    somme = 0;
    maximum = 0;
    minimum = 4095;
    variation = 0;
    nombrePics = 0;
    ancienneValeur = lireAmplitude();
    debut = millis();

    for(i = 0; i < nombreMesures; i++)
    {
        valeur = lireAmplitude();
        somme += valeur;
        if(valeur > maximum)
        {
            maximum = valeur;
        }
        if(valeur < minimum)
        {
          minimum = valeur;
        }
        difference = abs(valeur - ancienneValeur); 
        variation += difference;

        if(difference > seuil_pic && valeur > (somme / (i + 1) * 0.5))
        {
            nombrePics++;
        }
        ancienneValeur = valeur;
        delay(2);
    }
    resultat.maximum = maximum;
    resultat.minimum = minimum;
    resultat.moyenne = somme / nombreMesures;
    resultat.duree = millis() - debut;
    resultat.variation = variation / nombreMesures;
    resultat.nombrePics = nombrePics;

    return resultat;
}
