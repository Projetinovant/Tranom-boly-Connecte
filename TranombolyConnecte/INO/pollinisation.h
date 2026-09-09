#ifndef POLLINISATION_H
#define POLLINISATION_H

void initPollinisation();
void declencherPollinisation(unsigned long dureeMs);
void mettreAJourPollinisation(unsigned long maintenant);
void verifierPollinisationPeriodique(unsigned long maintenant, float luminosite);
bool pollinisationActive();

#endif
