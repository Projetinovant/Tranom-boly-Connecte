#include <Arduino.h>
#include "communication.h"
#include "sol.h"
#include "config.h"

// Protocole texte simple, une trame par ligne, tag au debut :
//   S;<freqDominante>;<ampDominante>;<64 valeurs separees par des virgules>
//   E;<etatSysteme 0-3>;<typeInsecte 0-3>;<confiance 0-1>;<repulsion 0/1>
//   M;<temperature>;<humiditeAir>;<luminosite>;<humiditeSol>
//   R;<etatReservoir 0-4>
// Commandes recues depuis Processing (une par ligne) :
//   ARROSER_EAU / ARROSER_ENGRAIS

static String ligneEntrante = "";

void initCommunication()
{
    Serial.begin(115200);
}

void envoyerSpectre(const ResultatSpectre &s)
{
    Serial.print("S;");
    Serial.print(s.frequenceDominante, 1);
    Serial.print(";");
    Serial.print(s.amplitudeDominante, 1);
    Serial.print(";");
    for(int i = 0; i < TAILLE_SPECTRE_AFFICHAGE; i++)
    {
        Serial.print((int)s.spectreAffichage[i]);
        if(i < TAILLE_SPECTRE_AFFICHAGE - 1) Serial.print(",");
    }
    Serial.println();
}

void envoyerEtat(EtatSysteme etat, TypeInsecte type, float confiance, bool repulsion)
{
    Serial.print("E;");
    Serial.print((int)etat);
    Serial.print(";");
    Serial.print((int)type);
    Serial.print(";");
    Serial.print(confiance, 2);
    Serial.print(";");
    Serial.println(repulsion ? 1 : 0);
}

void envoyerEnvironnement(const DonneesEnvironnement &env, int humiditeSolPourcent)
{
    Serial.print("M;");
    Serial.print(env.temperature, 1);
    Serial.print(";");
    Serial.print(env.humiditeAir, 1);
    Serial.print(";");
    Serial.print(env.luminosite);
    Serial.print(";");
    Serial.println(humiditeSolPourcent);
}

void envoyerReservoir(EtatReservoir etat)
{
    Serial.print("R;");
    Serial.println((int)etat);
}

void traiterCommandesEntrantes()
{
    while(Serial.available() > 0)
    {
        char c = Serial.read();
        if(c == '\n')
        {
            ligneEntrante.trim();
            if(ligneEntrante == "ARROSER_EAU")
            {
                demanderArrosageEau();
            }
            else if(ligneEntrante == "ARROSER_ENGRAIS")
            {
                demanderArrosageEngrais();
            }
            ligneEntrante = "";
        }
        else if(c != '\r')
        {
            ligneEntrante += c;
        }
    }
}
