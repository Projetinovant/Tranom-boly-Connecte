/* Tranom-boly Connecte -- selection.ino
   Logique de decision a trois niveaux :
     nuisible confirme -> porte fermee + repulsion
     utile confirme    -> fenetre d'ouverture temporisee
     inconnu           -> porte fermee, AUCUNE repulsion (exclusion passive)
   Le servo est detache hors mouvement : Timer1 libere pendant l'acquisition audio. */

#define ET_VEILLE   0
#define ET_OUVERT   1
#define ET_PRUDENCE 2
#define ET_ALERTE   3

#define ANGLE_FERME   10
#define ANGLE_OUVERT  95

#define DUREE_OUVERTURE 180000UL
#define DUREE_PRUDENCE   45000UL
#define DUREE_ALERTE     60000UL
#define ANTI_REBOND       3000UL

Servo servoPorte;

uint8_t  etat = ET_VEILLE;
uint8_t  porteOuverte = 0;
uint32_t tEtat = 0;
uint32_t tDernierMouvement = 0;

void selectionInit() {
  porteFermer();
  etat = ET_VEILLE;
  tEtat = millis();
}

uint8_t porteEstOuverte() {
  return porteOuverte;
}

static void bougerPorte(uint8_t angle) {
  if (millis() - tDernierMouvement < ANTI_REBOND) return;
  tDernierMouvement = millis();
  servoPorte.attach(PIN_SERVO);
  servoPorte.write(angle);
  delay(450);
  servoPorte.detach();
}

void porteOuvrir() {
  if (porteOuverte) return;
  bougerPorte(ANGLE_OUVERT);
  porteOuverte = 1;
  digitalWrite(PIN_LED_VERTE, HIGH);
  digitalWrite(PIN_LED_ROUGE, LOW);
  evenement(F("porte_ouverte"));
}

void porteFermer() {
  if (!porteOuverte && etat != ET_VEILLE) return;
  bougerPorte(ANGLE_FERME);
  porteOuverte = 0;
  digitalWrite(PIN_LED_VERTE, LOW);
  evenement(F("porte_fermee"));
}

static void changerEtat(uint8_t nouvel) {
  if (nouvel == etat) return;
  etat = nouvel;
  tEtat = millis();
}

void selectionMaj(uint8_t classe) {
  uint32_t ecoule = millis() - tEtat;

  if (classe == CL_UTILE) {
    if (etat == ET_ALERTE) {
      repulsionArreter();
      evenement(F("priorite_pollinisateur"));
    }
    porteOuvrir();
    changerEtat(ET_OUVERT);
    tEtat = millis();
    return;
  }

  switch (etat) {

    case ET_VEILLE:
      if (classe == CL_NUISIBLE) {
        porteFermer();
        repulsionDemarrer();
        changerEtat(ET_ALERTE);
      } else if (classe == CL_INCONNU) {
        porteFermer();
        changerEtat(ET_PRUDENCE);
      }
      break;

    case ET_OUVERT:
      if (classe == CL_NUISIBLE) {
        porteFermer();
        repulsionDemarrer();
        changerEtat(ET_ALERTE);
      } else if (ecoule > DUREE_OUVERTURE) {
        porteFermer();
        changerEtat(ET_VEILLE);
      }
      break;

    case ET_PRUDENCE:
      if (classe == CL_NUISIBLE) {
        repulsionDemarrer();
        changerEtat(ET_ALERTE);
      } else if (ecoule > DUREE_PRUDENCE) {
        changerEtat(ET_VEILLE);
      }
      break;

    case ET_ALERTE:
      if (ecoule > DUREE_ALERTE) {
        repulsionArreter();
        changerEtat(ET_PRUDENCE);
      }
      break;
  }

  digitalWrite(PIN_LED_ROUGE, (etat == ET_ALERTE) ? HIGH : LOW);
}

/* Pollinisation vibratile : uniquement porte ouverte, conditions favorables,
   et jamais pendant une fenetre d'acquisition. */
void vibrationPollinisation(int16_t tempC, int16_t humAir) {
  if (!porteOuverte) return;
  if (tempC < 21 || tempC > 27) return;
  if (humAir > 80) return;
  digitalWrite(PIN_VIBREUR, HIGH);
  delay(1500);
  digitalWrite(PIN_VIBREUR, LOW);
  evenement(F("vibration_pollinisation"));
}
