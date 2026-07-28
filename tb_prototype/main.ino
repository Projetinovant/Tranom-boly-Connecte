#include "microphone.h"
#include "detection.h"
#include "analyse.h"
#include "classification.h"

void setup()
{
    Serial.begin(115200);
    initMicrophone();
    Serial.println("Tranom-boly");
    Serial.println("demarrer la detection sonore");

    delay(1000);
    calibrer();
}

void loop()
{
    int valeur;
    valeur = lireAmplitude();
    
    if(sonDetecte(valeur))
    {
        Caracteristiques son = analyserSon();
        TypeInsecte type = classifierSon(son);

        switch(type)
        {
            case POLLINISATEUR:
                Serial.println("Pollinisateur probable");
                break;

            case AUXILIAIRE:
                Serial.println("Auxiliaire probable");
                break;

            case BRUIT_PARASITE:
                Serial.println("Bruit parasite");
                break;

            default:
                Serial.println("Aucune classification");
                break;
        }
        Serial.print("Maximum : ");
        Serial.println(son.maximum);

        Serial.print("Minimum : ");
        Serial.println(son.minimum);

        Serial.print("Moyenne : ");
        Serial.println(son.moyenne);

        Serial.print("Duree : ");
        Serial.println(son.duree);
        Serial.println(" ms");

        Serial.print("Variation : ");
        Serial.println(son.variation);

        Serial.print("Nombre de pics : ");
        Serial.println(son.nombrePics);
    }
    delay(100);
}