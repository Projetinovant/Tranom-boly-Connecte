// Interprete une ligne recue de l'ESP32 selon le protocole defini dans
// communication.cpp (cote firmware) : un tag suivi de champs separes par ';'

void traiterLigne(String ligne)
{
    if(ligne.length() == 0) return;

    String[] parties = split(ligne, ';');
    if(parties.length == 0) return;

    if(parties[0].equals("S"))
    {
        traiterSpectre(parties);
    }
    else if(parties[0].equals("E"))
    {
        traiterEtat(parties);
    }
    else if(parties[0].equals("M"))
    {
        traiterEnvironnement(parties);
    }
    else if(parties[0].equals("R"))
    {
        traiterReservoir(parties);
    }
    // Les trames "A;..." (autotest) ne sont pas affichees, juste ignorees ici
}

void traiterSpectre(String[] p)
{
    if(p.length < 4) return;
    freqDominante = float(p[1]);
    ampDominante = float(p[2]);
    String[] valeurs = split(p[3], ',');
    for(int i = 0; i < min(valeurs.length, spectre.length); i++)
    {
        spectre[i] = float(valeurs[i]);
    }
    donneesSpectreRecues = true;
}

void traiterEtat(String[] p)
{
    if(p.length < 5) return;
    etatSysteme = int(p[1]);
    typeInsecte = int(p[2]);
    confiance = float(p[3]);
    repulsionEnCours = (int(p[4]) == 1);
    donneesEtatRecues = true;
}

void traiterEnvironnement(String[] p)
{
    if(p.length < 5) return;
    temperature = float(p[1]);
    humiditeAir = float(p[2]);
    luminosite = int(p[3]);
    humiditeSol = int(p[4]);
    donneesEnvironnementRecues = true;
}

void traiterReservoir(String[] p)
{
    if(p.length < 2) return;
    etatReservoir = int(p[1]);
    donneesReservoirRecues = true;
}

// Envoie une commande a l'ESP32 (voir communication.cpp cote firmware)
void envoyerCommande(String commande)
{
    if(port != null)
    {
        port.write(commande + "\n");
    }
}
