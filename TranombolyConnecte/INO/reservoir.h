#ifndef RESERVOIR_H
#define RESERVOIR_H

enum EtatReservoir
{
    RESERVOIR_INACTIF,
    RESERVOIR_REMPLISSAGE_EAU,
    RESERVOIR_REMPLISSAGE_MELANGE,
    RESERVOIR_ATTENTE_MELANGE,
    RESERVOIR_DISTRIBUTION
};

void initReservoir();
void demanderArrosageEau();
void demanderArrosageEngrais();
void mettreAJourReservoir(unsigned long maintenant);
EtatReservoir etatReservoirActuel();
bool reservoirDisponible();

#endif
