#include "microphone.h"
#include "config.h"

// NOTE : ce fichier cible l'API timer du coeur Arduino-ESP32 v3.x
// (confirmee ici). Avec un coeur v2.x plus ancien, il faudrait revenir a
// timerBegin(0, 80, true) + timerAttachInterrupt(..., true) +
// timerAlarmWrite(...) + timerAlarmEnable(...).

static hw_timer_t *minuteur = NULL;
static portMUX_TYPE muxMinuteur = portMUX_INITIALIZER_UNLOCKED;

static volatile int16_t tamponAudio[TAILLE_FENETRE];
static volatile int indexTampon = 0;
static volatile bool tamponPret = false;
static volatile bool acquisitionActive = false;

void IRAM_ATTR interruptionEchantillonnage()
{
    portENTER_CRITICAL_ISR(&muxMinuteur);
    if(acquisitionActive && indexTampon < TAILLE_FENETRE)
    {
        tamponAudio[indexTampon] = analogRead(PIN_MIC_EXTERIEUR) - 2048;
        indexTampon++;
        if(indexTampon >= TAILLE_FENETRE)
        {
            tamponPret = true;
            acquisitionActive = false;
        }
    }
    portEXIT_CRITICAL_ISR(&muxMinuteur);
}

void initMicrophone()
{
    pinMode(PIN_MIC_EXTERIEUR, INPUT);
    pinMode(PIN_MIC_INTERIEUR, INPUT);
    analogReadResolution(12);

    unsigned long periodeMicrosecondes = 1000000UL / FREQ_ECHANTILLONNAGE;

    // API du coeur Arduino-ESP32 v3.x : timerBegin() prend directement une
    // frequence (ici 1 MHz -> 1 tick = 1 us), timerAttachInterrupt() ne
    // prend plus de parametre de front, et timerAlarm() regle ET active
    // l'alarme periodique en un seul appel (remplace timerAlarmWrite +
    // timerAlarmEnable de l'ancienne API v2.x).
    minuteur = timerBegin(1000000);
    timerAttachInterrupt(minuteur, &interruptionEchantillonnage);
    timerAlarm(minuteur, periodeMicrosecondes, true, 0);
}

void demarrerAcquisition()
{
    portENTER_CRITICAL(&muxMinuteur);
    indexTampon = 0;
    tamponPret = false;
    acquisitionActive = true;
    portEXIT_CRITICAL(&muxMinuteur);
}

bool acquisitionTerminee()
{
    return tamponPret;
}

int copierBuffer(int16_t *destination, int taille)
{
    int n = min(taille, TAILLE_FENETRE);
    portENTER_CRITICAL(&muxMinuteur);
    for(int i = 0; i < n; i++)
    {
        destination[i] = tamponAudio[i];
    }
    portEXIT_CRITICAL(&muxMinuteur);
    return n;
}

float lireNiveauInterieur()
{
    // RMS rapide sur quelques echantillons : sert de reference de bruit
    // ambiant pour la validation croisee dans classification.cpp
    const int nbEchantillons = 30;
    long sommeCarres = 0;
    for(int i = 0; i < nbEchantillons; i++)
    {
        int valeur = analogRead(PIN_MIC_INTERIEUR) - 2048;
        sommeCarres += (long)valeur * (long)valeur;
        delayMicroseconds(200);
    }
    return sqrt((float)sommeCarres / nbEchantillons);
}
