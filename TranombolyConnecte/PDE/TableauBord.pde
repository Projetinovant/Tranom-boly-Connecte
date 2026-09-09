import processing.serial.*;

Serial port;

// ==========================================================================
//  Toutes les valeurs ci-dessous ne sont mises a jour QUE par les trames
//  recues sur le port serie (voir Protocole.pde). Aucune simulation :
//  tant qu'une categorie de donnees n'a pas ete recue, son widget affiche
//  "en attente de donnees".
// ==========================================================================

float freqDominante = 0;
float ampDominante = 0;
float[] spectre = new float[64];
boolean donneesSpectreRecues = false;

int etatSysteme = 0;
int typeInsecte = 0;
float confiance = 0;
boolean repulsionEnCours = false;
boolean donneesEtatRecues = false;

float temperature = 25;
float humiditeAir = 50;
int luminosite = 0;
int humiditeSol = 0;
boolean donneesEnvironnementRecues = false;

int etatReservoir = 0;
boolean donneesReservoirRecues = false;

void setup()
{
    size(1000, 650);
    textFont(createFont("Arial", 14));

    printArray(Serial.list());
    // Par defaut on prend le premier port detecte : si ce n'est pas le bon,
    // remplacer l'index 0 par celui affiche dans la console au demarrage.
    if(Serial.list().length > 0)
    {
        port = new Serial(this, Serial.list()[0], 115200);
        port.bufferUntil('\n');
    }
}

void draw()
{
    background(20);

    dessinerEnTete();
    dessinerJaugeTemperature(150, 200, 90, temperature, donneesEnvironnementRecues);
    dessinerHumidite(320, 140, humiditeAir, humiditeSol, donneesEnvironnementRecues);
    dessinerSpectre(470, 60, 490, 220, spectre, freqDominante, donneesSpectreRecues);
    dessinerEtatSysteme(40, 340, etatSysteme, typeInsecte, confiance, repulsionEnCours, donneesEtatRecues);
    dessinerReservoir(470, 340, etatReservoir, donneesReservoirRecues);
}

void dessinerEnTete()
{
    fill(255);
    textSize(20);
    text("Tranom-boly Connecte - Tableau de bord", 40, 35);
    textSize(12);
    fill(150);
    text(port != null ? "Port serie connecte : " + Serial.list()[0] : "Aucun port serie detecte", 40, 55);
}

void serialEvent(Serial p)
{
    String ligne = p.readStringUntil('\n');
    if(ligne == null) return;
    traiterLigne(trim(ligne));
}
