#include <Arduino.h>
#include "decision.h"
#include "acces.h"
#include "repulsion.h"
#include "pollinisation.h"
#include "config.h"

static EtatSysteme etat = ETAT_VEILLE;
static unsigned long dernierChangementEtat = 0;

#define DUREE_MIN_PRUDENCE_MS  3000
#define DUREE_OUVERTURE_MS     8000
#define DUREE_ALERTE_MS        5000

void initDecision()
{
    pinMode(PIN_LED_ROUGE, OUTPUT);
    digitalWrite(PIN_LED_ROUGE, LOW);
    etat = ETAT_VEILLE;
    dernierChangementEtat = millis();
}

static void changerEtat(EtatSysteme nouvelEtat, unsigned long maintenant)
{
    if(nouvelEtat == etat)
    {
        return;
    }
    etat = nouvelEtat;
    dernierChangementEtat = maintenant;

    switch(etat)
    {
        case ETAT_VEILLE:
            fermerAcces();
            digitalWrite(PIN_LED_ROUGE, LOW);
            break;
        case ETAT_PRUDENCE:
            digitalWrite(PIN_LED_ROUGE, LOW);
            break;
        case ETAT_OUVERT:
            ouvrirAcces();
            digitalWrite(PIN_LED_ROUGE, LOW);
            declencherPollinisation(1500); // profite de la visite detectee pour assister la pollinisation
            break;
        case ETAT_ALERTE:
            fermerAcces();
            digitalWrite(PIN_LED_ROUGE, HIGH);
            declencherRepulsion();
            break;
    }
}

EtatSysteme mettreAJourDecision(TypeInsecte type, float confiance, unsigned long maintenant)
{
    unsigned long dansEtatDepuis = maintenant - dernierChangementEtat;

    switch(etat)
    {
        case ETAT_VEILLE:
            if(type == POLLINISATEUR && confiance > 0.5f)
            {
                changerEtat(ETAT_OUVERT, maintenant);
            }
            else if(type == NUISIBLE && confiance > 0.6f)
            {
                changerEtat(ETAT_ALERTE, maintenant);
            }
            else if(type == INCERTAIN)
            {
                changerEtat(ETAT_PRUDENCE, maintenant);
            }
            break;

        case ETAT_PRUDENCE:
            if(type == NUISIBLE && confiance > 0.5f)
            {
                changerEtat(ETAT_ALERTE, maintenant);
            }
            else if(type == POLLINISATEUR && confiance > 0.5f)
            {
                changerEtat(ETAT_OUVERT, maintenant);
            }
            else if(dansEtatDepuis > DUREE_MIN_PRUDENCE_MS && type == AUCUN)
            {
                changerEtat(ETAT_VEILLE, maintenant);
            }
            break;

        case ETAT_OUVERT:
            if(type == NUISIBLE && confiance > 0.6f)
            {
                changerEtat(ETAT_ALERTE, maintenant);
            }
            else if(dansEtatDepuis > DUREE_OUVERTURE_MS)
            {
                changerEtat(ETAT_VEILLE, maintenant);
            }
            break;

        case ETAT_ALERTE:
            if(dansEtatDepuis > DUREE_ALERTE_MS)
            {
                changerEtat((type == AUCUN) ? ETAT_VEILLE : ETAT_PRUDENCE, maintenant);
            }
            break;
    }

    return etat;
}

EtatSysteme etatActuel()
{
    return etat;
}
