/* Tranom-boly Connecte -- detection.ino
   Fichier principal. Le dossier du sketch DOIT s'appeler "detection".
   Les fichiers selection.ino et repulsion.ino sont compiles avec celui-ci.
   Bus I2C : LCD 0x27. */

#include <Wire.h>
#include <LiquidCrystal_I2C.h>
#include <Servo.h>

#define PIN_MIC_EXT   A0
#define PIN_MIC_INT   A1
#define PIN_SOL       A2
#define PIN_LDR       A3
#define PIN_SERVO      9
#define PIN_BUZZER     8
#define PIN_STROBE     7
#define PIN_LED_VERTE  6
#define PIN_LED_ROUGE  5
#define PIN_POMPE      4
#define PIN_VIBREUR    3

#define FS_HZ        2000
#define N_ECH        256
#define PERIODE_US   (1000000UL / FS_HZ)
#define N_BANDES     5
#define N_SONDES_MAX 4

#define B_LEP 0
#define B_XYL 1
#define B_API 2
#define B_DIP 3
#define B_MIC 4

#define CL_SILENCE  0
#define CL_UTILE    1
#define CL_NUISIBLE 2
#define CL_INCONNU  3

#define SEUIL_RMS      14.0f
#define RATIO_EXT_INT   1.6f
#define RATIO_DOMINANT  0.38f
#define N_HIST          5
#define N_CONFIRM       3

const uint8_t N_SONDES[N_BANDES] = { 4, 4, 4, 3, 3 };

const float SONDES[N_BANDES][N_SONDES_MAX] PROGMEM = {
  {  45.0f,  60.0f,  75.0f,  90.0f },
  { 105.0f, 120.0f, 140.0f, 158.0f },
  { 185.0f, 205.0f, 225.0f, 245.0f },
  { 265.0f, 300.0f, 340.0f,   0.0f },
  { 400.0f, 500.0f, 620.0f,   0.0f }
};

const uint8_t CLASSE_BANDE[N_BANDES] = {
  CL_NUISIBLE, CL_UTILE, CL_UTILE, CL_INCONNU, CL_INCONNU
};

const char NOM_BANDE[N_BANDES][5] = { "LEP", "XYL", "API", "DIP", "MIC" };

LiquidCrystal_I2C lcd(0x27, 16, 2);

int16_t  ech[N_ECH];
float    bande[N_BANDES];
float    rmsExt, rmsInt, confiance;
uint8_t  bandeDominante;
uint8_t  classeInstant   = CL_SILENCE;
uint8_t  classeConfirmee = CL_SILENCE;
uint8_t  hist[N_HIST];
uint8_t  histIdx = 0;
uint16_t humSol, lumiere;
uint32_t tLcd = 0, tCapteurs = 0;

extern uint8_t etat;   // defini dans selection.ino

void setup() {
  Serial.begin(115200);

  pinMode(PIN_BUZZER, OUTPUT);
  pinMode(PIN_STROBE, OUTPUT);
  pinMode(PIN_LED_VERTE, OUTPUT);
  pinMode(PIN_LED_ROUGE, OUTPUT);
  pinMode(PIN_POMPE, OUTPUT);
  pinMode(PIN_VIBREUR, OUTPUT);
  digitalWrite(PIN_POMPE, LOW);
  digitalWrite(PIN_VIBREUR, LOW);

  ADCSRA = (ADCSRA & 0xF8) | 0x05;   // prescaler 32 -> conversion ~26 us
  randomSeed(micros());     // A5 est occupe par le bus I2C

  lcd.init();
  lcd.backlight();
  lcd.print(F("Tranom-boly"));
  lcd.setCursor(0, 1);
  lcd.print(F("initialisation"));

  for (uint8_t i = 0; i < N_HIST; i++) hist[i] = CL_SILENCE;

  selectionInit();
  repulsionInit();

  delay(600);
  lcd.clear();
  Serial.println(F("E;0;demarrage"));
}

void loop() {
  repulsionSuspendre();
  analyser();
  classifier();
  envoyerAnalyse();

  selectionMaj(classeConfirmee);
  repulsionTick();

  if (millis() - tCapteurs > 2000) {
    tCapteurs = millis();
    lireCapteurs();
    envoyerCapteurs();
  }

  if (millis() - tLcd > 800) {
    tLcd = millis();
    majLcd();
  }
}

/* ---------- acquisition ---------- */

static void acquerir(uint8_t canal) {
  analogRead(canal);
  int32_t somme = 0;
  uint32_t t = micros();
  for (uint16_t i = 0; i < N_ECH; i++) {
    while ((int32_t)(micros() - t) < (int32_t)PERIODE_US) { }
    t += PERIODE_US;
    ech[i] = analogRead(canal);
    somme += ech[i];
  }
  int16_t moyenne = (int16_t)(somme / N_ECH);
  for (uint16_t i = 0; i < N_ECH; i++) ech[i] -= moyenne;
}

static float rmsBuffer() {
  uint32_t acc = 0;
  for (uint16_t i = 0; i < N_ECH; i++) acc += (uint32_t)((int32_t)ech[i] * ech[i]);
  return sqrt((float)acc / (float)N_ECH);
}

static float rmsRapide(uint8_t canal, uint16_t n) {
  analogRead(canal);
  int32_t somme = 0;
  int16_t tmp[64];
  if (n > 64) n = 64;
  uint32_t t = micros();
  for (uint16_t i = 0; i < n; i++) {
    while ((int32_t)(micros() - t) < (int32_t)PERIODE_US) { }
    t += PERIODE_US;
    tmp[i] = analogRead(canal);
    somme += tmp[i];
  }
  int16_t moy = (int16_t)(somme / n);
  uint32_t acc = 0;
  for (uint16_t i = 0; i < n; i++) {
    int32_t v = tmp[i] - moy;
    acc += (uint32_t)(v * v);
  }
  return sqrt((float)acc / (float)n);
}

/* ---------- analyse spectrale ---------- */

static float goertzel(float freq) {
  float coeff = 2.0f * cos(2.0f * PI * freq / (float)FS_HZ);
  float s0, s1 = 0.0f, s2 = 0.0f;
  for (uint16_t i = 0; i < N_ECH; i++) {
    s0 = coeff * s1 - s2 + (float)ech[i];
    s2 = s1;
    s1 = s0;
  }
  float p = s1 * s1 + s2 * s2 - coeff * s1 * s2;
  return (p > 0.0f) ? sqrt(p) : 0.0f;
}

void analyser() {
  rmsInt = rmsRapide(PIN_MIC_INT, 64);
  acquerir(PIN_MIC_EXT);
  rmsExt = rmsBuffer();

  for (uint8_t b = 0; b < N_BANDES; b++) bande[b] = 0.0f;

  if (rmsExt < SEUIL_RMS) return;

  for (uint8_t b = 0; b < N_BANDES; b++) {
    float acc = 0.0f;
    for (uint8_t s = 0; s < N_SONDES[b]; s++) {
      acc += goertzel(pgm_read_float(&SONDES[b][s]));
    }
    bande[b] = acc / (float)N_SONDES[b];
  }
}

void classifier() {
  float total = 0.0f, maxi = 0.0f;
  bandeDominante = 0;
  for (uint8_t b = 0; b < N_BANDES; b++) {
    total += bande[b];
    if (bande[b] > maxi) { maxi = bande[b]; bandeDominante = b; }
  }

  confiance = (total > 0.0f) ? (maxi / total) : 0.0f;

  if (rmsExt < SEUIL_RMS)                        classeInstant = CL_SILENCE;
  else if (rmsExt < RATIO_EXT_INT * rmsInt)      classeInstant = CL_SILENCE;
  else if (confiance < RATIO_DOMINANT)           classeInstant = CL_INCONNU;
  else                                           classeInstant = CLASSE_BANDE[bandeDominante];

  hist[histIdx] = classeInstant;
  histIdx = (histIdx + 1) % N_HIST;

  uint8_t compte[4] = { 0, 0, 0, 0 };
  for (uint8_t i = 0; i < N_HIST; i++) compte[hist[i]]++;

  if      (compte[CL_UTILE]    >= N_CONFIRM) classeConfirmee = CL_UTILE;
  else if (compte[CL_NUISIBLE] >= N_CONFIRM) classeConfirmee = CL_NUISIBLE;
  else if (compte[CL_SILENCE]  >= N_CONFIRM) classeConfirmee = CL_SILENCE;
  else                                       classeConfirmee = CL_INCONNU;
}

/* ---------- capteurs lents ---------- */

void lireCapteurs() {
  humSol  = analogRead(PIN_SOL);
  lumiere = analogRead(PIN_LDR);
}

/* ---------- liaison serie ---------- */

void envoyerAnalyse() {
  Serial.print(F("A;"));
  Serial.print(millis()); Serial.print(';');
  for (uint8_t b = 0; b < N_BANDES; b++) {
    Serial.print(bande[b], 1); Serial.print(';');
  }
  Serial.print(rmsExt, 1);        Serial.print(';');
  Serial.print(rmsInt, 1);        Serial.print(';');
  Serial.print(NOM_BANDE[bandeDominante]); Serial.print(';');
  Serial.print(classeInstant);    Serial.print(';');
  Serial.print(classeConfirmee);  Serial.print(';');
  Serial.print(confiance, 2);     Serial.print(';');
  Serial.println(etat);
}

void envoyerCapteurs() {
  Serial.print(F("C;"));
  Serial.print(millis()); Serial.print(';');
  Serial.print(humSol);   Serial.print(';');
  Serial.println(lumiere);
}

void evenement(const __FlashStringHelper *msg) {
  Serial.print(F("E;"));
  Serial.print(millis()); Serial.print(';');
  Serial.println(msg);
}

/* ---------- affichage local ---------- */

void majLcd() {
  lcd.setCursor(0, 0);
  switch (classeConfirmee) {
    case CL_UTILE:    lcd.print(F("UTILE   ")); break;
    case CL_NUISIBLE: lcd.print(F("NUISIBLE")); break;
    case CL_INCONNU:  lcd.print(F("INCONNU ")); break;
    default:          lcd.print(F("VEILLE  ")); break;
  }
  lcd.print(' ');
  lcd.print(NOM_BANDE[bandeDominante]);
  lcd.print(F("   "));

  lcd.setCursor(0, 1);
  lcd.print(F("P:"));
  if (porteEstOuverte()) lcd.print(F("OUV"));
  else                   lcd.print(F("FER"));
  lcd.print(F(" S:"));
  lcd.print(humSol / 10);
  lcd.print(F(" C:"));
  lcd.print((int)(confiance * 100));
  lcd.print(F("  "));
}
