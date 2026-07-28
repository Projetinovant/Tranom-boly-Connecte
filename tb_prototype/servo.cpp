#include <Arduino.h>
#include <ESP32Servo.h>
#include "servo.h"

const int SERVO_PIN = 18;
const int ANGLE_FERME = 0;
const int ANGLE_OUVERT = 90;
const int ANGLE_MIN = 0;
const int ANGLE_MAX = 180;

Servo servo;
int angleActuel;
angleActuel = ANGLE_FERME;

void initServo()
{
    Serial.println("Initialisation du servo");
    servo.attach(SERVO_PIN);
    angleActuel = ANGLE_FERME;
    servo.write(angleActuel);
    Serial.println("Fenetre fermee");
}

void deplacerServo(int angleFinal, int vitesse)
{
    int angle;
    if(angleFinal < ANGLE_MIN)
    {
        angleFinal = ANGLE_MIN;
    }
    if(angleFinal > ANGLE_MAX)
    {
        angleFinal = ANGLE_MAX;
    }
    if(angleFinal == angleActuel)
    {
        Serial.println("cette position actuelle");
        return;
    }

    Serial.print("angle final ");
    Serial.print(angleFinal);
    Serial.println(" degres");

    if(angleFinal > angleActuel)
    {
        for(angle = angleActuel; angle <= angleFinal; angle++)
        {
            servo.write(angle);
            delay(vitesse);
        }
    }
    else
    {
        for(angle = angleActuel; angle >= angleFinal; angle--)
        {
            servo.write(angle);
            delay(vitesse);
        }
    }

    angleActuel = angleFinal;

    Serial.print("Position actuelle : ");
    Serial.print(angleActuel);
    Serial.println(" degres");
}

void ouvrirFenetre()
{
    Serial.println("Ouverture complete");
    deplacerServo(ANGLE_OUVERT);
}

void fermerFenetre()
{
    Serial.println("Fermeture complete");
    deplacerServo(ANGLE_FERME);
}

void ouvrirAngle(int angle)
{
    Serial.print("Ouverture a ");
    Serial.print(angle);
    Serial.println(" degres");

    deplacerServo(angle);
}

int angleFenetre()
{
    return angleActuel;
}