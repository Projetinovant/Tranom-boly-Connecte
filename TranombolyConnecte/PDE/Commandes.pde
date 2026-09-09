// Boutons pour envoyer une commande a l'ESP32 (voir Protocole.pde -> envoyerCommande).
// Utile notamment pour l'engrais, qui n'est jamais declenche automatiquement
// cote firmware (pas de capteur EC/pH) - voir TranomBoly.ino.

float boutonEauX, boutonEauY, boutonEngraisX, boutonEngraisY;
float largeurBouton = 150, hauteurBouton = 32;

void dessinerBoutons(float x, float y)
{
    boutonEauX = x;
    boutonEauY = y;
    boutonEngraisX = x;
    boutonEngraisY = y + hauteurBouton + 10;

    dessinerUnBouton(boutonEauX, boutonEauY, "Arroser (eau)", color(90, 190, 230));
    dessinerUnBouton(boutonEngraisX, boutonEngraisY, "Arroser (engrais)", color(120, 200, 140));
}

void dessinerUnBouton(float x, float y, String libelle, color c)
{
    pushStyle();
    boolean survole = mouseX > x && mouseX < x + largeurBouton && mouseY > y && mouseY < y + hauteurBouton;
    fill(survole ? lerpColor(c, color(255), 0.2) : c);
    noStroke();
    rect(x, y, largeurBouton, hauteurBouton, 6);
    fill(20);
    textAlign(CENTER, CENTER);
    textSize(13);
    text(libelle, x + largeurBouton / 2, y + hauteurBouton / 2);
    textAlign(LEFT, BASELINE);
    popStyle();
}

void mousePressed()
{
    if(mouseX > boutonEauX && mouseX < boutonEauX + largeurBouton && mouseY > boutonEauY && mouseY < boutonEauY + hauteurBouton)
    {
        envoyerCommande("ARROSER_EAU");
    }
    else if(mouseX > boutonEngraisX && mouseX < boutonEngraisX + largeurBouton && mouseY > boutonEngraisY && mouseY < boutonEngraisY + hauteurBouton)
    {
        envoyerCommande("ARROSER_ENGRAIS");
    }
}
