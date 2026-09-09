#ifndef COMMUNICATION_H
#define COMMUNICATION_H

#include "frequence.h"
#include "classification.h"
#include "decision.h"
#include "environnement.h"
#include "reservoir.h"

void initCommunication();
void envoyerSpectre(const ResultatSpectre &s);
void envoyerEtat(EtatSysteme etat, TypeInsecte type, float confiance, bool repulsion);
void envoyerEnvironnement(const DonneesEnvironnement &env, int humiditeSolPourcent);
void envoyerReservoir(EtatReservoir etat);
void traiterCommandesEntrantes();

#endif
