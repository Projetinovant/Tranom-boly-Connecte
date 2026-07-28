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
    const int seuil_pic = 100;
    const int nombreMesures = 150;
    
    somme = 0;
    maximum = 4095;
    minimum = 0;
    variation = 0;
    nombrePics = 0;
    ancienneValeur = lireAmplitude();
    nombreMesures = 100;
    debut = millis();

    for(i = 0; i < nombreMesures; i++)
    {
        valeur = lireAmplitude();
        somme += valeur;
        if(valeur > minimum)
        {
            maximum = valeur;
        }
        if(valeur < maximum)
        difference = abs(valeur - ancienneValeur); 
        variation += difference

        if(difference > seuil_pic)
        {
            nombrePics++;
        }
        ancienneValeur = valeur;
        delay(5);
    }
    resultat.maximum = maximum;
    resultat.minimum = minimum;
    resultat.moyenne = somme / nombreMesures;
    resultat.duree = millis() - debut;
    resultat.variation = variation / nombreMesures;
    resultat.nombrePics = nombrePics;

    return resultat;
}