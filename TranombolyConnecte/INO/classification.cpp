#include "classification.h"

#define TAILLE_HISTORIQUE_DECISION 4
static TypeInsecte historiqueDecisions[TAILLE_HISTORIQUE_DECISION];
static int indexHistoriqueDecision = 0;

#define TEMPERATURE_REFERENCE 25.0f
#define COEFF_TEMPERATURE     0.015f  // ~+-1.5%/degre : approximation issue de la correlation
                                       // connue entre temperature et frequence de battement d'aile

// Bruit de fond adaptatif : mis a jour uniquement quand aucun signal n'est
// detecte, pour suivre les variations reelles du bruit ambiant (vent, heure
// de la journee...) plutot que de se fier a un seuil fixe.
static float bruitDeFondEMA = 40.0f;
#define ALPHA_EMA 0.05f
#define RATIO_ALERTE_BRUIT 1.5f

void initClassification()
{
    for(int i = 0; i < TAILLE_HISTORIQUE_DECISION; i++)
    {
        historiqueDecisions[i] = AUCUN;
    }
    bruitDeFondEMA = 40.0f;
}

static float facteurCompensationTemperature(float temperature)
{
    return 1.0f + (temperature - TEMPERATURE_REFERENCE) * COEFF_TEMPERATURE;
}

TypeInsecte classifier(const Caracteristiques &c, float *confiance)
{
    // --- Rejet immediat : signal sature (vent fort, choc sur le boitier) ---
    if(c.spectre.saturation)
    {
        *confiance = 0.0f;
        return INCERTAIN;
    }

    // --- Seuil de presence adaptatif, base sur le bruit de fond mesure ---
    if(c.spectre.energieTotale < bruitDeFondEMA * RATIO_ALERTE_BRUIT)
    {
        bruitDeFondEMA = bruitDeFondEMA * (1 - ALPHA_EMA) + c.spectre.energieTotale * ALPHA_EMA;
        *confiance = 1.0f;
        return AUCUN;
    }

    // --- Validation croisee entre les 2 microphones : si le micro interieur
    // (bruit ambiant) capte une energie comparable au micro exterieur, le
    // signal est probablement du bruit general et non un insecte localise ---
    const float RATIO_MIN_EXT_INT = 1.4f;
    if(c.niveauInterieur > 0 && (c.spectre.amplitudeDominante / c.niveauInterieur) < RATIO_MIN_EXT_INT)
    {
        *confiance = 0.5f;
        return INCERTAIN;
    }

    float facteur = facteurCompensationTemperature(c.temperatureActuelle);

    // --- Score par bande, pondere par la regularite temporelle ---
    float scorePapillon = c.spectre.energiePapillon;
    float scorePollinisateur = c.spectre.energiePollinisateur;
    float scoreNuisibleVol = c.spectre.energieNuisibleVol;

    // Vol soutenu/regulier -> renforce la piste pollinisateur.
    // Vol tres irregulier -> renforce la piste nuisible/inconnu.
    if(c.spectre.regulariteTemporelle < 15.0f)
    {
        scorePollinisateur *= 1.2f;
    }
    else if(c.spectre.regulariteTemporelle > 60.0f)
    {
        scoreNuisibleVol *= 1.15f;
    }

    // --- Signature "vol d'insecte" : presence d'une harmonique marquee
    // (rejette le bruit large-bande qui n'a pas cette structure) ---
    float ratioHarmonique = (c.spectre.amplitudeDominante > 0)
        ? (c.spectre.energieHarmonique2 / c.spectre.amplitudeDominante) : 0;
    bool signatureInsecteProbable = (ratioHarmonique > 0.15f && ratioHarmonique < 0.9f);

    float meilleurScore = max(scorePapillon, max(scorePollinisateur, scoreNuisibleVol));

    if(!signatureInsecteProbable || meilleurScore < 25.0f)
    {
        *confiance = 0.4f;
        return INCERTAIN;
    }

    *confiance = min(1.0f, meilleurScore / 100.0f);

    // Frequence dominante compensee en temperature, comparee aux bandes de reference
    float freqCompensee = c.spectre.frequenceDominante / facteur;

    if(scorePapillon == meilleurScore || (freqCompensee >= BANDE_PAPILLON_MIN && freqCompensee <= BANDE_PAPILLON_MAX))
    {
        return NUISIBLE;
    }
    if(scorePollinisateur == meilleurScore || (freqCompensee >= BANDE_POLLINISATEUR_MIN && freqCompensee <= BANDE_POLLINISATEUR_MAX))
    {
        return POLLINISATEUR;
    }
    if(scoreNuisibleVol == meilleurScore || (freqCompensee >= BANDE_NUISIBLE_VOL_MIN && freqCompensee <= BANDE_NUISIBLE_VOL_MAX))
    {
        return NUISIBLE;
    }

    *confiance = 0.3f;
    return INCERTAIN;
}

TypeInsecte classifierAvecConfirmation(const Caracteristiques &c, float *confiance)
{
    TypeInsecte decisionInstantanee = classifier(c, confiance);

    historiqueDecisions[indexHistoriqueDecision] = decisionInstantanee;
    indexHistoriqueDecision = (indexHistoriqueDecision + 1) % TAILLE_HISTORIQUE_DECISION;

    int comptePollinisateur = 0;
    int compteNuisible = 0;
    for(int i = 0; i < TAILLE_HISTORIQUE_DECISION; i++)
    {
        if(historiqueDecisions[i] == POLLINISATEUR) comptePollinisateur++;
        if(historiqueDecisions[i] == NUISIBLE) compteNuisible++;
    }

    // Une majorite sur l'historique recent est necessaire pour valider un
    // changement d'etat : evite les oscillations rapides (faux positifs isoles)
    if(compteNuisible >= (TAILLE_HISTORIQUE_DECISION / 2) + 1)
    {
        return NUISIBLE;
    }
    if(comptePollinisateur >= (TAILLE_HISTORIQUE_DECISION / 2) + 1)
    {
        return POLLINISATEUR;
    }
    return (decisionInstantanee == AUCUN) ? AUCUN : INCERTAIN;
}
