#include "microphone.h"
#include "detection.h"
#include "analyse.h"
#include "classification.h"
#include "Led.hpp"
#include "servo.h"

Led ledVerte(11);
Led ledRouge(12);
Led ledJaune(13);

void afficheType(TypeInsecte type)
{
  Serial.print("Type d'insecte detecte : ");
  Serial.println(type);
}
void setup()
{
    Serial.begin(9600);
    initMicrophone();
    initServo();
    initCapteurs();
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
        afficheType(type);
        switch(type)
        {
            case POLLINISATEUR:
                Serial.println("Pollinisateur probable");
                ledVerte.allumer();
                delay(1000);
                ledVerte.eteindre();
                ouvrirFenetre();
                break;

            case AUXILIAIRE:
                Serial.println("Auxiliaire probable");
                ledJaune.allumer();
                delay(1000);
                ledJaune.eteindre();
                ouvrirAngle(45);
                break;

            case BRUIT_PARASITE:
                Serial.println("Bruit parasite");
                ledRouge.allumer();
                delay(1000);
                ledRouge.eteindre();
                fermerFenetre();
                break;

            default:
                Serial.println("Aucune classification");
                fermerFenetre();
                break;
        }
    }
   
    Serial.print("Temperature: ");
    Serial.println(temperature());

    Serial.print("Humidite du sol: ");
    Serial.println(humidite());

    arrosage();
    ajoutEngrais();
    delay(2000);
}
