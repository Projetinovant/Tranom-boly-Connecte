#ifndef FREQUENCE_H
#define FREQUENCE_H

#include <Arduino.h>
#include "microphone.h"

// Bandes de reference issues de la litterature acoustique entomologique
// (battement d'aile des insectes). A affiner par calibration terrain,
// comme le dossier technique l'assume deja pour la classification sonore.
#define BANDE_PAPILLON_MIN        50.0f    // Lepidopteres (chenilles/papillons), vol lent
#define BANDE_PAPILLON_MAX        80.0f
#define BANDE_POLLINISATEUR_MIN   120.0f   // Abeilles/bourdons : vol + pollinisation vibratile
#define BANDE_POLLINISATEUR_MAX   400.0f
#define BANDE_NUISIBLE_VOL_MIN    400.0f   // Mouches / moustiques / autres dipteres
#define BANDE_NUISIBLE_VOL_MAX    1500.0f

#define TAILLE_SPECTRE_AFFICHAGE  64

struct ResultatSpectre
{
    float frequenceDominante;
    float amplitudeDominante;
    float energieHarmonique2;                       // energie vers 2x la frequence dominante
    float regulariteTemporelle;                      // ecart-type de la freq. dominante recente
    float energiePapillon;
    float energiePollinisateur;
    float energieNuisibleVol;
    float energieTotale;
    bool saturation;                                  // vrai si le signal a clippe (vent fort, choc...)
    float spectreAffichage[TAILLE_SPECTRE_AFFICHAGE]; // sous-echantillonne, pour le tableau de bord
};

void initAnalyseFrequence();
ResultatSpectre analyserFenetre(int16_t *echantillons, int taille);
float energieGoertzel(int16_t *echantillons, int taille, float frequenceCible, float frequenceEchantillonnage);

#endif
