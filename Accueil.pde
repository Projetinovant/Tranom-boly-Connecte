// ---- Page d'accueil ----
void drawAccueil() {
  float cy = height/2 - 100;

  fill(cGreen());
  textFont(fontBig); textSize(34);
  textAlign(CENTER, CENTER);
  text("Tranom-boliko", width/2, cy);

  fill(100);
  textFont(fontReg); textSize(14);
  text("Votre maison connectée et vos cultures, au même endroit.", width/2, cy + 38);

  fill(150);
  textSize(11);
  text("Météo en temps réel · Suivi des capteurs · Ventes & marchés · Espace de gestion", width/2, cy + 60);

  button(width/2 - 220, cy + 100, 200, 46, "Voir le tableau de bord", true);
  button(width/2 + 20,  cy + 100, 200, 46, "Vente & Marchés", false);
}

void accueilMousePressed(float mx, float my) {
  float cy = height/2 - 100;
  if (clicked(width/2 - 220, cy + 100, 200, 46, mx, my)) currentScreen = "dashboard";
  if (clicked(width/2 + 20,  cy + 100, 200, 46, mx, my)) currentScreen = "vente";
}
