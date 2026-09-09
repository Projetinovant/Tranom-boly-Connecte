#ifndef ENVIRONNEMENT_H
#define ENVIRONNEMENT_H

struct DonneesEnvironnement
{
    float temperature;
    float humiditeAir;
    int luminosite;
    bool lectureValide;
};

void initEnvironnement();
DonneesEnvironnement lireEnvironnement();

#endif
