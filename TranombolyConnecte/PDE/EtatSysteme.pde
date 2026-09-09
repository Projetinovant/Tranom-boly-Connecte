String[] NOMS_ETAT      = { "Veille", "Prudence", "Ouvert", "Alerte" };
String[] NOMS_INSECTE    = { "Aucun", "Pollinisateur", "Nuisible", "Incertain" };
String[] NOMS_RESERVOIR  = { "Inactif", "Remplissage eau", "Remplissage melange", "Attente melange", "Distribution" };

void dessinerEtatSysteme(float x, float y, int etat, int type, float conf, boolean repulsion, boolean valide)
{
    pushStyle();
    fill(255);
    textSize(16);
    text("Etat du systeme", x, y);
    textSize(14);

    if(valide)
    {
        color couleurEtat = (etat == 3) ? color(230, 90, 60) : (etat == 2) ? color(90, 220, 120) : color(200);
        fill(couleurEtat);
        text("Etat : " + NOMS_ETAT[constrain(etat, 0, NOMS_ETAT.length - 1)], x, y + 30);
        fill(255);
        text("Detection : " + NOMS_INSECTE[constrain(type, 0, NOMS_INSECTE.length - 1)]
             + "  (confiance " + nf(conf * 100, 0, 0) + " %)", x, y + 55);
        text("Repulsion active : " + (repulsion ? "oui" : "non"), x, y + 80);
    }
    else
    {
        fill(120);
        text("En attente de donnees...", x, y + 30);
    }
    popStyle();
}

void dessinerReservoir(float x, float y, int etat, boolean valide)
{
    pushStyle();
    fill(255);
    textSize(16);
    text("Reservoir eau / engrais", x, y);
    textSize(14);
    fill(valide ? color(200) : color(120));
    text(valide ? NOMS_RESERVOIR[constrain(etat, 0, NOMS_RESERVOIR.length - 1)] : "En attente de donnees...", x, y + 30);

    dessinerBoutons(x, y + 60);
    popStyle();
}
