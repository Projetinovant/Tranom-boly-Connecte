#include "microphone.h"
#include "detection.h"
#include "analyse.h"
#include "classification.h"
#include "servo.h"

void setup()
{
    Serial.begin(9600);
    initMicrophone();
    initServo();
    Serial.println("Tranom-boly");
    Serial.println("demarrer la detection sonore");

    delay(1000);
    calibrer();
}

void loop()
{
    int amplitude;
    amplitude = lireAmplitude();
    Serial.print("Amplitude : ");
    Serial.println(amplitude);

    if(sonDetecte(amplitude))
    {
        Serial.println("BRUIT DETECTE");
    }
    if(sonDetecte(amplitude))
    {
        Caracteristiques son = analyserSon();
       
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

        TypeInsecte type = classifierSon(son);
        switch(type)
        {
            case POLLINISATEUR:
                Serial.println("Pollinisateur probable");
                ouvrirFenetre();
                break;

            case AUXILIAIRE:
                Serial.println("Auxiliaire probable");
                ouvrirAngle(45);
                break;

            case BRUIT_PARASITE:
                Serial.println("Bruit parasite");
                fermerFenetre();
                break;

            default:
                Serial.println("Aucune classification");
                fermerFenetre();
                break;
        }
    }
    delay(100);
}
