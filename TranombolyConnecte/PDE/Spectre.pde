void dessinerSpectre(float x, float y, float largeur, float hauteur, float[] donnees, float freqDom, boolean valide)
{
    pushStyle();
    noStroke();
    fill(30);
    rect(x, y, largeur, hauteur);

    fill(255);
    textSize(14);
    text("Spectre audio (temps reel)", x, y - 10);

    if(valide)
    {
        float maxValeur = 1;
        for(int i = 0; i < donnees.length; i++)
        {
            maxValeur = max(maxValeur, donnees[i]);
        }

        float largeurBarre = largeur / donnees.length;
        for(int i = 0; i < donnees.length; i++)
        {
            float h = map(donnees[i], 0, maxValeur, 0, hauteur - 10);
            fill(90, 190, 230);
            rect(x + i * largeurBarre, y + hauteur - h, largeurBarre - 1, h);
        }

        fill(255);
        textSize(12);
        text("Frequence dominante : " + nf(freqDom, 0, 1) + " Hz", x, y + hauteur + 20);
    }
    else
    {
        fill(120);
        textSize(12);
        text("En attente de donnees...", x + 10, y + hauteur / 2);
    }
    popStyle();
}
