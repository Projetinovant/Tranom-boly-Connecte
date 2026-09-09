#include "config.h"
#include "microphone.h"
#include "frequence.h"
#include "classification.h"
#include "decision.h"
#include "acces.h"
#include "repulsion.h"
#include "pollinisation.h"
#include "environnement.h"
#include "sol.h"
#include "reservoir.h"
#include "communication.h"

static int16_t tamponAnalyse[TAILLE_FENETRE];

#define INTERVALLE_ENVIRONNEMENT_MS   2500
#define INTERVALLE_RESERVOIR_CHECK_MS 60000UL  // verifie le besoin d'eau toutes les minutes
#define INTERVALLE_RESERVOIR_ENVOI_MS 1000UL

static unsigned long dernierEnvironnement = 0;
static unsigned long dernierCheckSol = 0;
static unsigned long dernierEnvoiReservoir = 0;

void setup()
{
    initCommunication();

    // Autotest de demarrage : verifie que le capteur d'ambiance repond avant
    // de faire confiance au reste de la chaine de decision
    initEnvironnement();
    DonneesEnvironnement testInitial = lireEnvironnement();
    delay(2000);
    testInitial = lireEnvironnement();
    Serial.print("A;DHT11=");
    Serial.println(testInitial.lectureValide ? "OK" : "ECHEC");

    initMicrophone();
    initAnalyseFrequence();
    initClassification();
    initAcces();
    initDecision();
    initRepulsion();
    initPollinisation();
    initSol();
    initReservoir();

    randomSeed(analogRead(PIN_MIC_INTERIEUR));

    demarrerAcquisition();
}

void loop()
{
    unsigned long maintenant = millis();

    // --- 1) Chaine acoustique : detection -> analyse -> classification -> decision ---
    if(acquisitionTerminee())
    {
        if(repulsionActive() || pollinisationActive())
        {
            // Fenetre potentiellement contaminee par le bruit de nos propres
            // actionneurs (buzzer/vibreur) : on l'ignore et on relance une
            // acquisition propre plutot que de risquer un faux classement.
            demarrerAcquisition();
        }
        else
        {
            int n = copierBuffer(tamponAnalyse, TAILLE_FENETRE);
            ResultatSpectre spectre = analyserFenetre(tamponAnalyse, n);

            Caracteristiques c;
            c.spectre = spectre;
            c.niveauInterieur = lireNiveauInterieur();

            DonneesEnvironnement env = lireEnvironnement();
            c.temperatureActuelle = env.lectureValide ? env.temperature : 25.0f;

            float confiance;
            TypeInsecte type = classifierAvecConfirmation(c, &confiance);
            EtatSysteme etat = mettreAJourDecision(type, confiance, maintenant);

            envoyerSpectre(spectre);
            envoyerEtat(etat, type, confiance, repulsionActive());

            demarrerAcquisition();
        }
    }

    // --- 2) Environnement (temperature/humidite air, luminosite, sol) ---
    if(maintenant - dernierEnvironnement > INTERVALLE_ENVIRONNEMENT_MS)
    {
        DonneesEnvironnement env = lireEnvironnement();
        int humiditeSol = lireHumiditeSolPourcent();
        envoyerEnvironnement(env, humiditeSol);
        verifierPollinisationPeriodique(maintenant, env.luminosite);
        dernierEnvironnement = maintenant;
    }

    // --- 3) Irrigation automatique (eau seule) selon l'humidite du sol ---
    // L'engrais n'est PAS declenche automatiquement ici : sans capteur
    // EC/pH, seule une commande explicite depuis Processing (ARROSER_ENGRAIS)
    // ouvre les 2 portes du reservoir - choix assume, pas une lacune cachee.
    if(maintenant - dernierCheckSol > INTERVALLE_RESERVOIR_CHECK_MS)
    {
        if(solABesoinEau() && reservoirDisponible())
        {
            demanderArrosageEau();
        }
        dernierCheckSol = maintenant;
    }

    // --- 4) Mises a jour non-bloquantes des actionneurs ---
    mettreAJourRepulsion(maintenant);
    mettreAJourPollinisation(maintenant);
    mettreAJourReservoir(maintenant);

    if(maintenant - dernierEnvoiReservoir > INTERVALLE_RESERVOIR_ENVOI_MS)
    {
        envoyerReservoir(etatReservoirActuel());
        dernierEnvoiReservoir = maintenant;
    }

    // --- 5) Commandes entrantes depuis Processing (arrosage manuel engrais, etc.) ---
    traiterCommandesEntrantes();
}
