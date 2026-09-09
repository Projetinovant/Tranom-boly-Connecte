#ifndef CLASSIFICATION_H
#define CLASSIFICATION_H

#include "frequence.h"

enum TypeInsecte
{
    AUCUN,
    POLLINISATEUR,
    NUISIBLE,
    INCERTAIN     // principe de precaution : signal present mais non tranche avec confiance
};

struct Caracteristiques
{
    ResultatSpectre spectre;
    float niveauInterieur;      // RMS micro interieur (reference de bruit ambiant)
    float temperatureActuelle;  // deg C, pour compensation des bandes de frequence
};

void initClassification();
TypeInsecte classifier(const Caracteristiques &c, float *confiance);
TypeInsecte classifierAvecConfirmation(const Caracteristiques &c, float *confiance);

#endif
