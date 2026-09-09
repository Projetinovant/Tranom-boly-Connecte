#ifndef PORTE_H
#define PORTE_H

#include <ESP32Servo.h>

// Une "Porte" generique actionnee par un servomoteur.
// Reutilisee par : la porte anti-nuisible (acces.cpp) et les 3 portes
// du reservoir eau/engrais (reservoir.cpp). Un seul endroit a corriger
// si la logique de mouvement doit changer.
struct Porte
{
    Servo servo;
    int broche;
    int angleFerme;
    int angleOuvert;
    int angleActuel;
    bool ouverte;
};

void initPorte(Porte &porte, int broche, int angleFerme, int angleOuvert);
void ouvrirPorte(Porte &porte, int vitesseMs = 15);
void fermerPorte(Porte &porte, int vitesseMs = 15);
bool porteEstOuverte(const Porte &porte);

#endif
