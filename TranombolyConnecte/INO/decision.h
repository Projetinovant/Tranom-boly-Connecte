#ifndef DECISION_H
#define DECISION_H

#include "classification.h"

enum EtatSysteme
{
    ETAT_VEILLE,
    ETAT_PRUDENCE,
    ETAT_OUVERT,
    ETAT_ALERTE
};

void initDecision();
EtatSysteme mettreAJourDecision(TypeInsecte type, float confiance, unsigned long maintenant);
EtatSysteme etatActuel();

#endif
