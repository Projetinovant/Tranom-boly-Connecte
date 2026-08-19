class Sensors {
  float temperature = 24.6, humidityAir = 68, humiditySoil = 42, luminosity = 850;
  int etatSysteme = 0;   // 0=Veille 1=Prudence 2=Pollinisateur(porte ouverte) 3=ALERTE
  int typeInsecte = 0;   // 0=Aucun 1=Pollinisateur 2=Nuisible 3=Incertain
  float confiance = 0;
  boolean repulsion = false;
  boolean porteOuverte = false;
  boolean irrigationActive = false;
  float freqDominante = 0, ampDominante = 0;
  float[] spectre = new float[64];
  boolean fromHardware = false;
  long lastHardwareMsg = -999999;
  long lastUpdate = 0;

  void update() {
    if (fromHardware && millis() - lastHardwareMsg > 10000) {
      fromHardware = false; // plus de trame recue depuis 10s -> connexion consideree perdue
    }
    if (fromHardware) return; // donnees deja a jour via serialEvent() (17_Serial.pde)

    if (millis() - lastUpdate < 30000) return;
    lastUpdate = millis();
    temperature   += random(-0.2, 0.2);
    humidityAir    = constrain(humidityAir + random(-1, 1), 30, 100);
    humiditySoil   = constrain(humiditySoil + random(-0.5, 0.5), 20, 100);
    luminosity     = max(0, luminosity + random(-10, 10));
    if (store != null) store.addSensorSample(temperature, humidityAir, humiditySoil, luminosity);
  }
}

String etatLabel(int e) {
  if (e == 0) return "Veille";
  if (e == 1) return "Prudence";
  if (e == 2) return "Pollinisateur";
  if (e == 3) return "ALERTE nuisible";
  return "?";
}
color etatColorFor(int e) {
  if (e == 0) return cGreen();
  if (e == 1) return cYellow();
  if (e == 2) return cBlue();
  if (e == 3) return cRed();
  return cGrayLight();
}
String typeLabel(int t) {
  if (t == 0) return "Aucun";
  if (t == 1) return "Pollinisateur";
  if (t == 2) return "Nuisible";
  if (t == 3) return "Incertain";
  return "?";
}

void drawDashboard() {
  float top = navH + 24;
  fill(cGreen());
  textFont(fontBig); textSize(22); textAlign(LEFT, TOP);
  text(currentUser != null ? ("Bonjour, " + currentUser + " !") : "Bonjour !", 40, top);
  fill(140);
  textFont(fontReg); textSize(12);
  text(sensors.fromHardware ? "Systeme Tranom-boliko connecte en direct." : "Environnement simule -- ESP32 non detecte.", 40, top + 30);

  textAlign(RIGHT, TOP);
  fill(140); textSize(11);
  String[] joursFr = {"Dimanche","Lundi","Mardi","Mercredi","Jeudi","Vendredi","Samedi"};
  int dow = java.time.LocalDate.now().getDayOfWeek().getValue() % 7;
  text(joursFr[dow] + " " + day() + " " + moisFr(month()) + " " + year(), width - 40, top);
  fill(cText());
  textFont(fontBold); textSize(26);
  text(nf(hour(),2) + ":" + nf(minute(),2) + ":" + nf(second(),2), width - 40, top + 16);

  float gy = top + 60;

  // --- Ligne 1 : environnement ---
  String[] labels1 = {"Temperature","Humidite de l'air","Humidite du sol","Luminosite","Etat du systeme"};
  String[] values1 = {
    nf(sensors.temperature,0,1) + " degC",
    round(sensors.humidityAir) + " %",
    round(sensors.humiditySoil) + " %",
    round(sensors.luminosity) + " lux",
    etatLabel(sensors.etatSysteme)
  };
  color[] badgeC1 = {cGreen(),cGreen(),cGreen(),cGreen(), etatColorFor(sensors.etatSysteme)};

  // --- Ligne 2 : systeme anti-nuisible ---
  String[] labels2 = {"Porte anti-nuisible","Insecte detecte","Repulsion","Irrigation (pompe)","Connexion ESP32"};
  String[] values2 = {
    sensors.porteOuverte ? "Ouverte" : "Fermee",
    typeLabel(sensors.typeInsecte) + " (" + round(sensors.confiance*100) + "%)",
    sensors.repulsion ? "Active" : "Inactive",
    sensors.irrigationActive ? "En cours" : "Inactive",
    sensors.fromHardware ? "Connecte (reel)" : "Simulation"
  };
  color[] badgeC2 = {
    sensors.porteOuverte ? cBlue() : cGrayLight(),
    sensors.typeInsecte == 2 ? cRed() : (sensors.typeInsecte == 1 ? cBlue() : cGreen()),
    sensors.repulsion ? cRed() : cGreen(),
    sensors.irrigationActive ? cBlue() : cGreen(),
    sensors.fromHardware ? cGreen() : cOrange()
  };

  int cols = 5;
  float gw = (width - 80 - (cols-1)*12) / (float) cols;
  float gh = 80;
  for (int i = 0; i < 5; i++) {
    float px = 40 + i * (gw + 12);
    card(px, gy, gw, gh);
    badge(px + gw - 62, gy + 10, "", badgeC1[i], badgeC1[i]);
    fill(cText()); textFont(fontBold); textSize(14); textAlign(LEFT, TOP);
    text(values1[i], px + 12, gy + 32, gw-20, 20);
    fill(150); textFont(fontReg); textSize(10);
    text(labels1[i], px + 12, gy + 58);
  }
  float gy2 = gy + gh + 12;
  for (int i = 0; i < 5; i++) {
    float px = 40 + i * (gw + 12);
    card(px, gy2, gw, gh);
    badge(px + gw - 62, gy2 + 10, "", badgeC2[i], badgeC2[i]);
    fill(cText()); textFont(fontBold); textSize(13); textAlign(LEFT, TOP);
    text(values2[i], px + 12, gy2 + 32, gw-20, 24);
    fill(150); textFont(fontReg); textSize(10);
    text(labels2[i], px + 12, gy2 + 58);
  }

  // --- Commandes manuelles ---
  float by0 = gy2 + gh + 16;
  fill(cText()); textFont(fontBold); textSize(12); textAlign(LEFT, TOP);
  text("Commandes manuelles" + (sensors.fromHardware ? "" : " (necessite l'ESP32 connecte)"), 40, by0);
  float bw0 = (width - 80 - 3*12) / 4.0;
  button(40, by0 + 20, bw0, 40, "Ouvrir la porte", false);
  button(40 + (bw0+12), by0 + 20, bw0, 40, "Fermer la porte", false);
  button(40 + 2*(bw0+12), by0 + 20, bw0, 40, "Tester la repulsion", false);
  button(40 + 3*(bw0+12), by0 + 20, bw0, 40, "Arroser maintenant", true);

  float chartY = by0 + 20 + 40 + 16;
  float chartH = 220;

  float chartW = (width - 80) * 0.65;
  card(40, chartY, chartW, chartH);
  fill(cText());
  textFont(fontBold); textSize(14);
  textAlign(LEFT, TOP);
  boolean realHistory = (store != null && store.sensorHistory.size() >= 3);
  text("Evolution de l'environnement" + (realHistory ? "" : " (exemple)"), 56, chartY + 16);
  drawLineChart(56, chartY + 48, chartW - 32, chartH - 76);

  float wx = 40 + chartW + 16;
  float ww = (width - 80) - chartW - 16;
  card(wx, chartY, ww, chartH);
  fill(cText());
  textFont(fontBold); textSize(14);
  textAlign(LEFT, TOP);
  text("Meteo actuelle", wx + 16, chartY + 16);
  fill(150);
  textFont(fontReg); textSize(10);
  text("Antananarivo, Madagascar", wx + 16, chartY + 36);

  if (weatherLoading) {
    fill(160); textAlign(CENTER, CENTER);
    text("Chargement...", wx + ww/2, chartY + chartH/2);
  } else if (weatherError != null) {
    fill(cRed()); textAlign(CENTER, CENTER); textSize(11);
    text(weatherError, wx + ww/2, chartY + chartH/2);
  } else if (weather != null) {
    drawWeatherIcon(wx + 42, chartY + 74, 50, weather.weatherCode);
    fill(cText());
    textFont(fontBold); textSize(20);
    textAlign(LEFT, TOP);
    text(nf(weather.temperature,0,1) + " degC", wx + 70, chartY + 56);
    fill(130);
    textFont(fontReg); textSize(10);
    text(weatherLabel(weather.weatherCode), wx + 70, chartY + 80);

    String[] mini  = {round(weather.humidity) + "%", nf(weather.wind,0,0) + " km/h", nf(weather.rain,0,1) + " mm"};
    String[] miniL = {"Humidite","Vent","Pluie"};
    float mw = (ww - 32) / 3.0;
    for (int i = 0; i < 3; i++) {
      float px = wx + 16 + i * mw;
      fill(cText());
      textFont(fontBold); textSize(11);
      textAlign(CENTER, CENTER);
      text(mini[i], px + mw/2, chartY + 118);
      fill(150);
      textFont(fontReg); textSize(9);
      text(miniL[i], px + mw/2, chartY + 132);
    }
  }

  float by = chartY + chartH + 16;
  float bh = 170;
  float bw = (width - 80 - 16) / 2.0;

  card(40, by, bw, bh);
  fill(cText());
  textFont(fontBold); textSize(14);
  textAlign(LEFT, TOP);
  text("Spectre audio (KY-037)" + (sensors.fromHardware ? "" : " -- inactif"), 56, by + 14);
  drawSpectre(56, by + 36, bw - 32, bh - 50);

  card(40 + bw + 16, by, bw, bh);
  fill(cText());
  textFont(fontBold); textSize(14);
  textAlign(LEFT, TOP);
  text("Activites recentes", 56 + bw + 16, by + 14);
  drawActivities(56 + bw + 16, by + 40, bw - 32);
}

void drawSpectre(float x, float y, float w, float h) {
  stroke(240);
  line(x, y+h, x+w, y+h);
  noStroke();
  int n = sensors.spectre.length;
  float barW = w / (float) n;
  float maxVal = 1;
  for (int i = 0; i < n; i++) maxVal = max(maxVal, sensors.spectre[i]);
  for (int i = 0; i < n; i++) {
    float bh2 = map(sensors.spectre[i], 0, maxVal, 0, h);
    fill(sensors.fromHardware ? color(59,130,246) : color(210));
    rect(x + i*barW, y + h - bh2, max(1,barW-1), bh2);
  }
  fill(150); textFont(fontReg); textSize(9); textAlign(LEFT, TOP);
  text("Freq. dominante : " + nf(sensors.freqDominante,0,0) + " Hz", x, y + h + 4);
}

void drawLineChart(float x, float y, float w, float h) {
  stroke(240);
  for (int i = 0; i <= 4; i++) {
    float ly = y + h - i * h/4.0;
    line(x, ly, x + w, ly);
  }
  noStroke();

  boolean realHistory = (store != null && store.sensorHistory.size() >= 3);
  String[] xLabels;
  float[] tempD, humAirD, humSolD, luxD;

  if (realHistory) {
    int n = min(store.sensorHistory.size(), 30);
    int start = store.sensorHistory.size() - n;
    tempD = new float[n]; humAirD = new float[n]; humSolD = new float[n]; luxD = new float[n];
    xLabels = new String[n];
    for (int i = 0; i < n; i++) {
      SensorSample s = store.sensorHistory.get(start + i);
      tempD[i] = s.temp; humAirD[i] = s.humAir; humSolD[i] = s.humSol; luxD[i] = s.lux;
      java.util.Date dte = new java.util.Date(s.t);
      xLabels[i] = new java.text.SimpleDateFormat("HH:mm").format(dte);
    }
  } else {
    tempD = new float[]{23,24,24,25,24,24,25};
    humAirD = new float[]{65,67,66,68,70,70,69};
    humSolD = new float[]{40,41,42,43,44,44,43};
    luxD = new float[]{820,850,870,890,800,790,860};
    xLabels = new String[]{"J-6","J-5","J-4","J-3","J-2","J-1","Auj."};
  }

  drawChartLine(tempD,   x, y, w, h, 0, 50,   color(249,115,22));
  drawChartLine(humAirD, x, y, w, h, 0, 100,  color(59,130,246));
  drawChartLine(humSolD, x, y, w, h, 0, 100,  color(6,182,212));
  drawChartLine(luxD,    x, y, w, h, 0, 1000, color(234,179,8));

  fill(140);
  textFont(fontReg); textSize(8);
  textAlign(CENTER, TOP);
  int step = max(1, xLabels.length / 7);
  for (int i = 0; i < xLabels.length; i += step) {
    float px = x + i * (w / (float) max(1,(xLabels.length - 1)));
    text(xLabels[i], px, y + h + 6);
  }

  String[] leg = {"Temperature","Humidite air","Humidite sol","Luminosite"};
  color[] legC = {color(249,115,22), color(59,130,246), color(6,182,212), color(234,179,8)};
  float lx = x;
  textAlign(LEFT, CENTER); textSize(9);
  for (int i = 0; i < leg.length; i++) {
    fill(legC[i]); rect(lx, y - 14, 9, 9);
    fill(90); text(leg[i], lx + 12, y - 9);
    lx += textWidth(leg[i]) + 26;
  }
}

void drawChartLine(float[] data, float x, float y, float w, float h, float vmin, float vmax, color c) {
  stroke(c); strokeWeight(2); noFill();
  beginShape();
  for (int i = 0; i < data.length; i++) {
    float px = x + i * (w / (float) max(1,(data.length - 1)));
    float py = y + h - (constrain(data[i], vmin, vmax) - vmin) / (vmax - vmin) * h;
    vertex(px, py);
  }
  endShape();
  noStroke();
}

void drawActivities(float x, float y, float w) {
  ArrayList<Notif> list = (store != null) ? store.notifs : new ArrayList<Notif>();
  float ry = y;
  if (list.isEmpty()) {
    fill(170); textAlign(CENTER, TOP); textSize(11);
    text("Aucune activite pour l'instant.", x + w/2, ry + 20);
    return;
  }
  for (int i = 0; i < list.size() && i < 3; i++) {
    Notif n = list.get(i);
    fill(cGreen()); noStroke(); ellipse(x + 6, ry + 6, 8, 8);
    fill(cText()); textFont(fontReg); textSize(11); textAlign(LEFT, TOP);
    text(n.message, x + 18, ry, w - 90, 30);
    fill(160); textAlign(RIGHT, TOP); textSize(9);
    text(n.time, x + w, ry);
    ry += 40;
  }
}

void dashboardMousePressed(float mx, float my) {
  float top = navH + 24;
  float gy = top + 60;
  float gh = 80;
  float gy2 = gy + gh + 12;
  float by0 = gy2 + gh + 16;
  float bw0 = (width - 80 - 3*12) / 4.0;

  if (clicked(40, by0 + 20, bw0, 40, mx, my)) { ouvrirPorteManuel(); if (store!=null) store.addNotif("Ouverture manuelle de la porte demandee"); return; }
  if (clicked(40 + (bw0+12), by0 + 20, bw0, 40, mx, my)) { fermerPorteManuel(); if (store!=null) store.addNotif("Fermeture manuelle de la porte demandee"); return; }
  if (clicked(40 + 2*(bw0+12), by0 + 20, bw0, 40, mx, my)) { testerRepulsion(); if (store!=null) store.addNotif("Test de repulsion declenche"); return; }
  if (clicked(40 + 3*(bw0+12), by0 + 20, bw0, 40, mx, my)) { arroserEau(); if (store!=null) store.addNotif("Arrosage manuel demande"); return; }
}
