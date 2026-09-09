#ifndef MICROPHONE_H
#define MICROPHONE_H

#include <Arduino.h>

#define TAILLE_FENETRE          512    // echantillons par analyse (resolution frequentielle ~7.8 Hz)
#define FREQ_ECHANTILLONNAGE    4000   // Hz - Nyquist a 2000 Hz, couvre la plage nuisible 100-1500 Hz avec marge

void initMicrophone();
void demarrerAcquisition();
bool acquisitionTerminee();
int copierBuffer(int16_t *destination, int taille);
float lireNiveauInterieur();

#endif
