/* Tranom-boly Connecte -- repulsion.ino
   Repulsion NON LETALE et complementaire : la barriere principale reste
   l'exclusion physique (porte fermee). Le son et la lumiere ne sont qu'un
   appoint, randomises pour retarder l'accoutumance, et plafonnes par un
   budget horaire pour eviter la nuisance permanente. */

#define BUDGET_MS_PAR_HEURE  90000UL
#define FENETRE_BUDGET     3600000UL
#define REPOS_MIN_MS         15000UL
#define MOTIF_MIN_MS           400UL
#define MOTIF_MAX_MS          1600UL
#define FREQ_MIN_HZ           1800
#define FREQ_MAX_HZ           4200
#define SALVE_MS               120

uint8_t  repulsionActive = 0;
uint32_t tProchainMotif = 0;
uint32_t tDebutSession = 0;
uint32_t tFinSession = 0;
uint32_t budgetUtilise = 0;
uint32_t tFenetreBudget = 0;

void repulsionInit() {
  noTone(PIN_BUZZER);
  digitalWrite(PIN_STROBE, LOW);
  repulsionActive = 0;
  budgetUtilise = 0;
  tFenetreBudget = millis();
}

static void majBudget() {
  if (millis() - tFenetreBudget > FENETRE_BUDGET) {
    tFenetreBudget = millis();
    budgetUtilise = 0;
  }
}

uint8_t repulsionDisponible() {
  majBudget();
  if (budgetUtilise >= BUDGET_MS_PAR_HEURE) return 0;
  if (millis() - tFinSession < REPOS_MIN_MS)  return 0;
  return 1;
}

void repulsionDemarrer() {
  if (repulsionActive) return;
  if (!repulsionDisponible()) {
    evenement(F("repulsion_budget_epuise"));
    return;
  }
  repulsionActive = 1;
  tDebutSession = millis();
  tProchainMotif = millis();
  evenement(F("repulsion_demarree"));
}

void repulsionArreter() {
  if (!repulsionActive) return;
  repulsionActive = 0;
  noTone(PIN_BUZZER);
  digitalWrite(PIN_STROBE, LOW);
  tFinSession = millis();
  budgetUtilise += (tFinSession - tDebutSession);
  evenement(F("repulsion_arretee"));
}

void repulsionSuspendre() {
  noTone(PIN_BUZZER);
  digitalWrite(PIN_STROBE, LOW);
}

void repulsionTick() {
  if (!repulsionActive) return;

  majBudget();
  if (budgetUtilise + (millis() - tDebutSession) >= BUDGET_MS_PAR_HEURE) {
    repulsionArreter();
    return;
  }

  if ((int32_t)(millis() - tProchainMotif) < 0) return;

  uint16_t freq = random(FREQ_MIN_HZ, FREQ_MAX_HZ);
  uint8_t  salves = random(1, 4);

  for (uint8_t i = 0; i < salves; i++) {
    tone(PIN_BUZZER, freq + random(-200, 200), SALVE_MS);
    digitalWrite(PIN_STROBE, HIGH);
    delay(SALVE_MS / 2);
    digitalWrite(PIN_STROBE, LOW);
    delay(SALVE_MS / 2 + random(30, 90));
  }
  noTone(PIN_BUZZER);

  tProchainMotif = millis() + random(MOTIF_MIN_MS, MOTIF_MAX_MS);
}
