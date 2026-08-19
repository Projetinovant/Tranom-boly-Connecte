// ---- Palette ----
color cGreen()     { return color(22,163,74);  }
color cGreenDark()  { return color(21,128,61);  }
color cGreenBg()   { return color(240,253,244);}
color cGray()      { return color(107,114,128);}
color cGrayLight() { return color(156,163,175);}
color cBorder()    { return color(229,231,235);}
color cRed()       { return color(220,38,38);  }
color cBlue()      { return color(37,99,235);  }
color cOrange()    { return color(234,88,12);  }
color cYellow()    { return color(234,179,8);  }
color cPurple()    { return color(147,51,234); }
color cCyan()      { return color(6,182,212);  }
color cText()      { return color(17,24,39);   }

// ---- Cartes / conteneurs ----
void card(float x, float y, float w, float h) {
  fill(255);
  stroke(cBorder());
  strokeWeight(1);
  rect(x, y, w, h, 14);
  noStroke();
}

// ---- Boutons ----
boolean button(float x, float y, float w, float h, String label, boolean primary) {
  boolean hover = mouseX > x && mouseX < x + w && mouseY > y && mouseY < y + h;
  if (primary) {
    fill(hover ? cGreenDark() : cGreen());
    noStroke();
  } else {
    fill(hover ? color(248) : 255);
    stroke(cBorder());
  }
  rect(x, y, w, h, 8);
  noStroke();
  fill(primary ? 255 : 60);
  textAlign(CENTER, CENTER);
  textFont(fontReg); textSize(13);
  text(label, x + w/2, y + h/2);
  return hover;
}

boolean clicked(float x, float y, float w, float h, float mx, float my) {
  return mx > x && mx < x + w && my > y && my < y + h;
}

// ---- Formatage ----
String formatAr(double n) {
  String s = String.format("%,.0f", n).replace(",", " ");
  return s + " Ar";
}

void badge(float x, float y, String txt, color c, color bg) {
  textFont(fontReg); textSize(10);
  float w = textWidth(txt) + 16;
  fill(bg); noStroke();
  rect(x, y, w, 18, 9);
  fill(c);
  textAlign(CENTER, CENTER);
  text(txt, x + w/2, y + 9);
}

// ---- Coche vectorielle (remplace les emoji ✓ pour la portabilité) ----
void drawCheck(float cx, float cy, float s, color c) {
  stroke(c); strokeWeight(3);
  line(cx - s*0.5, cy,        cx - s*0.1, cy + s*0.4);
  line(cx - s*0.1, cy + s*0.4, cx + s*0.5, cy - s*0.4);
  noStroke();
}

// ---- Icônes météo vectorielles (remplacent les emoji, non fiables selon l'OS) ----
void drawWeatherIcon(float cx, float cy, float s, int code) {
  noStroke();
  if (code == 0) {
    // Ensoleillé
    fill(250,204,21);
    ellipse(cx, cy, s*0.55, s*0.55);
    stroke(250,204,21); strokeWeight(2);
    for (int i = 0; i < 8; i++) {
      float a = i * PI/4;
      line(cx+cos(a)*s*0.38, cy+sin(a)*s*0.38, cx+cos(a)*s*0.52, cy+sin(a)*s*0.52);
    }
    noStroke();
  } else if (code == 1 || code == 2) {
    // Partiellement nuageux
    fill(250,204,21);
    ellipse(cx - s*0.15, cy - s*0.12, s*0.32, s*0.32);
    fill(226,232,240);
    ellipse(cx + s*0.08, cy + s*0.08, s*0.5, s*0.38);
  } else if (code == 3 || code == 45 || code == 48) {
    // Nuageux / brumeux
    fill(203,213,225);
    ellipse(cx - s*0.16, cy, s*0.4, s*0.34);
    ellipse(cx + s*0.14, cy, s*0.46, s*0.4);
  } else if ((code >= 51 && code <= 67) || (code >= 80 && code <= 82)) {
    // Pluie / bruine / averses
    fill(148,163,184);
    ellipse(cx, cy - s*0.12, s*0.55, s*0.4);
    stroke(59,130,246); strokeWeight(2);
    for (int i = -1; i <= 1; i++) {
      line(cx + i*s*0.16, cy + s*0.14, cx + i*s*0.16 - 3, cy + s*0.3);
    }
    noStroke();
  } else if (code >= 71 && code <= 77) {
    // Neige
    fill(226,232,240);
    ellipse(cx, cy - s*0.12, s*0.55, s*0.4);
    fill(255);
    for (int i = -1; i <= 1; i++) ellipse(cx + i*s*0.16, cy + s*0.28, 5, 5);
  } else if (code >= 95) {
    // Orage
    fill(100,116,139);
    ellipse(cx, cy - s*0.12, s*0.55, s*0.4);
    fill(250,204,21);
    triangle(cx, cy + s*0.08, cx - s*0.1, cy + s*0.34, cx + s*0.05, cy + s*0.2);
  } else {
    fill(180);
    ellipse(cx, cy, s*0.5, s*0.5);
  }
}
