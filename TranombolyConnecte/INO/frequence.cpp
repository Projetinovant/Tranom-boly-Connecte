#include "frequence.h"
#include <arduinoFFT.h>

// NOTE DE COMPATIBILITE : l'API d'arduinoFFT differe entre la version 1.x
// (classe "arduinoFFT", methodes Windowing()/Compute()/MajorPeak() qui ne
// renvoie que la frequence) et la version 2.x (classe template
// "ArduinoFFT<double>", methodes windowing()/compute()/majorPeak(&f,&a)
// utilisee ci-dessous). Verifier la version installee via le Gestionnaire
// de bibliotheques si la compilation echoue sur ce bloc.

static double vReal[TAILLE_FENETRE];
static double vImag[TAILLE_FENETRE];

#define TAILLE_HISTORIQUE_FREQ 5
static float historiqueFrequences[TAILLE_HISTORIQUE_FREQ];
static int indexHistorique = 0;
static bool historiqueRempli = false;

void initAnalyseFrequence()
{
    indexHistorique = 0;
    historiqueRempli = false;
    for(int i = 0; i < TAILLE_HISTORIQUE_FREQ; i++)
    {
        historiqueFrequences[i] = 0;
    }
}

static float calculerEcartType(float *valeurs, int taille)
{
    float moyenne = 0;
    for(int i = 0; i < taille; i++)
    {
        moyenne += valeurs[i];
    }
    moyenne /= taille;

    float sommeCarresEcarts = 0;
    for(int i = 0; i < taille; i++)
    {
        float ecart = valeurs[i] - moyenne;
        sommeCarresEcarts += ecart * ecart;
    }
    return sqrt(sommeCarresEcarts / taille);
}

float energieGoertzel(int16_t *echantillons, int taille, float frequenceCible, float frequenceEchantillonnage)
{
    int k = (int)(0.5f + ((float)taille * frequenceCible) / frequenceEchantillonnage);
    float omega = (2.0f * PI * k) / taille;
    float coeff = 2.0f * cos(omega);
    float q0, q1 = 0, q2 = 0;

    for(int i = 0; i < taille; i++)
    {
        q0 = coeff * q1 - q2 + (float)echantillons[i];
        q2 = q1;
        q1 = q0;
    }

    float reel = q1 - q2 * cos(omega);
    float imaginaire = q2 * sin(omega);
    return sqrt(reel * reel + imaginaire * imaginaire) / (taille / 2.0f);
}

static bool detecterSaturation(int16_t *echantillons, int taille)
{
    // Un ADC 12 bits centre sur 2048 sature vers +-2047. Si une part
    // significative des echantillons est proche de cette limite, le signal
    // est probablement du bruit mecanique/vent trop fort pour etre fiable.
    int compteSature = 0;
    for(int i = 0; i < taille; i++)
    {
        if(abs(echantillons[i]) > 1950)
        {
            compteSature++;
        }
    }
    return (compteSature > taille / 10);
}

ResultatSpectre analyserFenetre(int16_t *echantillons, int taille)
{
    ResultatSpectre resultat;

    resultat.saturation = detecterSaturation(echantillons, taille);

    // --- 1) FFT complete : spectre pour l'affichage + frequence dominante ---
    for(int i = 0; i < taille; i++)
    {
        vReal[i] = (double)echantillons[i];
        vImag[i] = 0.0;
    }

    ArduinoFFT<double> FFT = ArduinoFFT<double>(vReal, vImag, (uint16_t)taille, (double)FREQ_ECHANTILLONNAGE);
    FFT.windowing(FFTWindow::Hamming, FFTDirection::Forward);
    FFT.compute(FFTDirection::Forward);
    FFT.complexToMagnitude();

    double frequencePic = 0, amplitudePic = 0;
    FFT.majorPeak(&frequencePic, &amplitudePic);
    resultat.frequenceDominante = (float)frequencePic;
    resultat.amplitudeDominante = (float)amplitudePic;

    // Sous-echantillonnage du spectre utile (moitie basse du tableau FFT)
    // pour un envoi compact vers le tableau de bord Processing
    int nbBinsUtiles = taille / 2;
    int pas = max(1, nbBinsUtiles / TAILLE_SPECTRE_AFFICHAGE);
    float energieTotale = 0;
    for(int i = 0; i < TAILLE_SPECTRE_AFFICHAGE; i++)
    {
        int indexSource = i * pas;
        float magnitude = (indexSource < nbBinsUtiles) ? (float)vReal[indexSource] : 0;
        resultat.spectreAffichage[i] = magnitude;
        energieTotale += magnitude;
    }
    resultat.energieTotale = energieTotale;

    // --- 2) Harmonique : energie autour de 2x la frequence dominante ---
    resultat.energieHarmonique2 = (resultat.frequenceDominante > 0)
        ? energieGoertzel(echantillons, taille, resultat.frequenceDominante * 2.0f, FREQ_ECHANTILLONNAGE)
        : 0;

    // --- 3) Goertzel cible sur les 3 bandes de reference (centre de bande) ---
    resultat.energiePapillon = energieGoertzel(echantillons, taille, (BANDE_PAPILLON_MIN + BANDE_PAPILLON_MAX) / 2.0f, FREQ_ECHANTILLONNAGE);
    resultat.energiePollinisateur = energieGoertzel(echantillons, taille, (BANDE_POLLINISATEUR_MIN + BANDE_POLLINISATEUR_MAX) / 2.0f, FREQ_ECHANTILLONNAGE);
    resultat.energieNuisibleVol = energieGoertzel(echantillons, taille, (BANDE_NUISIBLE_VOL_MIN + BANDE_NUISIBLE_VOL_MAX) / 2.0f, FREQ_ECHANTILLONNAGE);

    // --- 4) Regularite temporelle : ecart-type de la freq. dominante recente ---
    historiqueFrequences[indexHistorique] = resultat.frequenceDominante;
    indexHistorique = (indexHistorique + 1) % TAILLE_HISTORIQUE_FREQ;
    if(indexHistorique == 0)
    {
        historiqueRempli = true;
    }
    resultat.regulariteTemporelle = historiqueRempli
        ? calculerEcartType(historiqueFrequences, TAILLE_HISTORIQUE_FREQ)
        : 9999; // pas assez de mesures : incertitude maximale par prudence

    return resultat;
}
