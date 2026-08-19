// ---- Barre de navigation ----
String[] navLabels  = {"Accueil","Tableau de bord","Espaces utilisateurs","Vente & Marches","Meteo","Aide"};
String[] navScreens = {"accueil","dashboard","espaces","vente","meteo","help"};
float navH = 64;

void drawNavbar() {
  fill(255);
  noStroke();
  rect(0, 0, width, navH);
  stroke(230);
  line(0, navH, width, navH);
  noStroke();

  fill(cGreen());
  textFont(fontBold); textSize(18);
  textAlign(LEFT, CENTER);
  text("Tranom-boliko", 24, navH/2 - 8);
  fill(150);
  textFont(fontReg); textSize(10);
  text("JGTech", 24, navH/2 + 10);

  float x = 210;
  textFont(fontReg); textSize(13);
  for (int i = 0; i < navLabels.length; i++) {
    float w = textWidth(navLabels[i]) + 26;
    boolean active = currentScreen.equals(navScreens[i]);
    fill(active ? cGreen() : color(80));
    textAlign(LEFT, CENTER);
    text(navLabels[i], x, navH/2);
    if (active) {
      stroke(cGreen()); strokeWeight(2);
      line(x, navH - 10, x + textWidth(navLabels[i]), navH - 10);
      noStroke();
    }
    x += w;
  }
  // lien Contact separe (pas assez de place sinon)
  float cxw = textWidth("Contact") + 26;
  boolean contactActive = currentScreen.equals("contact");
  fill(contactActive ? cGreen() : color(80));
  text("Contact", x, navH/2);
  if (contactActive) { stroke(cGreen()); strokeWeight(2); line(x, navH-10, x+textWidth("Contact"), navH-10); noStroke(); }

  drawNotifBell();

  // menu utilisateur
  textAlign(RIGHT, CENTER);
  if (currentUser != null) {
    fill(cText()); textFont(fontBold); textSize(11);
    text(currentUser, width - 24, navH/2 - 8);
    fill(cRed()); textFont(fontReg); textSize(10);
    text("Deconnexion", width - 24, navH/2 + 8);
  } else {
    fill(cGreen()); textFont(fontBold); textSize(12);
    text("Connexion", width - 24, navH/2);
  }
}

boolean handleNavbarClick(float mx, float my) {
  if (notifMousePressed(mx, my)) return true;

  if (my > navH || my < 0) return false;

  // menu utilisateur (zone large a droite)
  if (mx > width - 170 && mx < width - 20) {
    if (currentUser != null) { logoutUser(); return true; }
    else { authAfterLoginScreen = "accueil"; currentScreen = "login"; return true; }
  }

  float x = 210;
  textFont(fontReg); textSize(13);
  for (int i = 0; i < navLabels.length; i++) {
    float w = textWidth(navLabels[i]) + 26;
    if (mx > x - 8 && mx < x + w && my > 0 && my < navH) {
      gotoScreen(navScreens[i]);
      return true;
    }
    x += w;
  }
  float cxw = textWidth("Contact") + 26;
  if (mx > x - 8 && mx < x + cxw && my > 0 && my < navH) {
    currentScreen = "contact";
    return true;
  }
  return false;
}
