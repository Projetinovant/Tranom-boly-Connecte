#ifndef SERVO_H
#define SERVO_H

void initServo();
void ouvrirFenetre();
void fermerFenetre();
void ouvrirAngle(int angle);
void deplacerServo(int angleFinal, int vitesse = 15);
int angleFenetre();

#endif