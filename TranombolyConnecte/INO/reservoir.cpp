#include <Arduino.h>
#include "reservoir.h"
#include "porte.h"
#include "config.h"

// Principe : 2 bouteilles inversees (goulot en bas, en permanence ouvertes)
// s'auto-limitent en hauteur par effet de vase communicant / poche d'air
// (comme un abreuvoir). Les portes controlees ici n'ont pas besoin de doser
// un debit : elles isolent ou connectent chaque bouteille au reservoir.
//   - Eau seule       : porte_eau ouverte seule, puis distribution.
//   - Engrais (NPK...) : porte_eau + porte_engrais ouvertes ensemble pour
//                        que les 2 liquides se melangent en tombant, puis
//                        distribution.
// Sans capteur EC/pH, le dosage reste empirique (duree/geometrie), pas
// asservi chimiquement - assume clairement, comme le reste du projet.

#define ANGLE_FERME  0
#define ANGLE_OUVERT 60

static Porte porteEau;
static Porte porteEngrais;
static Porte porteDistribution;

static EtatReservoir etat = RESERVOIR_INACTIF;
static unsigned long debutEtat = 0;
static bool demandeEauEnAttente = false;
static bool demandeEngraisEnAttente = false;

// Delais de securite : si le capteur de niveau ne declenche jamais (panne,
// bouteille vide), on ne laisse pas les portes ouvertes indefiniment.
#define DELAI_MAX_REMPLISSAGE_MS   30000UL
#define DELAI_MELANGE_MS            4000UL
#define DELAI_DISTRIBUTION_MS      10000UL

void initReservoir()
{
    initPorte(porteEau, PIN_SERVO_PORTE_EAU, ANGLE_FERME, ANGLE_OUVERT);
    initPorte(porteEngrais, PIN_SERVO_PORTE_ENGRAIS, ANGLE_FERME, ANGLE_OUVERT);
    initPorte(porteDistribution, PIN_SERVO_PORTE_DISTRIBUTION, ANGLE_FERME, ANGLE_OUVERT);
    pinMode(PIN_NIVEAU_RESERVOIR, INPUT_PULLDOWN);
    etat = RESERVOIR_INACTIF;
    debutEtat = millis();
}

static bool reservoirPlein()
{
    return digitalRead(PIN_NIVEAU_RESERVOIR) == HIGH;
}

void demanderArrosageEau()
{
    if(etat == RESERVOIR_INACTIF)
    {
        demandeEauEnAttente = true;
    }
}

void demanderArrosageEngrais()
{
    if(etat == RESERVOIR_INACTIF)
    {
        demandeEngraisEnAttente = true;
    }
}

static void changerEtatReservoir(EtatReservoir nouvel, unsigned long maintenant)
{
    etat = nouvel;
    debutEtat = maintenant;
}

void mettreAJourReservoir(unsigned long maintenant)
{
    unsigned long dansEtatDepuis = maintenant - debutEtat;

    switch(etat)
    {
        case RESERVOIR_INACTIF:
            if(demandeEngraisEnAttente)
            {
                demandeEngraisEnAttente = false;
                demandeEauEnAttente = false;
                ouvrirPorte(porteEau);
                ouvrirPorte(porteEngrais);
                changerEtatReservoir(RESERVOIR_REMPLISSAGE_MELANGE, maintenant);
            }
            else if(demandeEauEnAttente)
            {
                demandeEauEnAttente = false;
                ouvrirPorte(porteEau);
                changerEtatReservoir(RESERVOIR_REMPLISSAGE_EAU, maintenant);
            }
            break;

        case RESERVOIR_REMPLISSAGE_EAU:
            if(reservoirPlein() || dansEtatDepuis > DELAI_MAX_REMPLISSAGE_MS)
            {
                fermerPorte(porteEau);
                changerEtatReservoir(RESERVOIR_DISTRIBUTION, maintenant);
            }
            break;

        case RESERVOIR_REMPLISSAGE_MELANGE:
            if(reservoirPlein() || dansEtatDepuis > DELAI_MAX_REMPLISSAGE_MS)
            {
                fermerPorte(porteEau);
                fermerPorte(porteEngrais);
                changerEtatReservoir(RESERVOIR_ATTENTE_MELANGE, maintenant);
            }
            break;

        case RESERVOIR_ATTENTE_MELANGE:
            // Court delai pour laisser l'eau et l'engrais se melanger avant distribution
            if(dansEtatDepuis > DELAI_MELANGE_MS)
            {
                changerEtatReservoir(RESERVOIR_DISTRIBUTION, maintenant);
            }
            break;

        case RESERVOIR_DISTRIBUTION:
            // Verrou de securite : jamais de flux direct bouteille -> sol,
            // la distribution n'agit que quand les 2 portes d'entree sont fermees
            if(!porteEstOuverte(porteEau) && !porteEstOuverte(porteEngrais))
            {
                if(!porteEstOuverte(porteDistribution))
                {
                    ouvrirPorte(porteDistribution);
                    debutEtat = maintenant; // chrono de distribution demarre a l'ouverture reelle
                }
                else if((maintenant - debutEtat) > DELAI_DISTRIBUTION_MS)
                {
                    fermerPorte(porteDistribution);
                    changerEtatReservoir(RESERVOIR_INACTIF, maintenant);
                }
            }
            break;
    }
}

EtatReservoir etatReservoirActuel()
{
    return etat;
}

bool reservoirDisponible()
{
    return etat == RESERVOIR_INACTIF;
}
