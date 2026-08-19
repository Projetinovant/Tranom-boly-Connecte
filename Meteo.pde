// ---- Page Météo (données réelles, voir 05_WeatherService.pde) ----
void drawMeteo() {
  float top = navH + 30;
  fill(cGreen());
  textFont(fontBig); textSize(24); textAlign(LEFT, TOP);
  text("Météo", 40, top);
  fill(140);
  textFont(fontReg); textSize(12);
  text("Antananarivo, Madagascar — Données en temps réel", 40, top + 34);

  float cy = top + 70;

  if (weatherLoading) {
    fill(150); textAlign(CENTER, CENTER); textSize(13);
    text("Chargement de la météo...", width/2, cy + 80);
    return;
  }
  if (weatherError != null) {
    fill(254,226,226); noStroke(); rect(40, cy, width - 80, 60, 12);
    fill(cRed()); textAlign(CENTER, CENTER);
    text(weatherError, width/2, cy + 30);
    return;
  }
  if (weather == null) return;

  // Carte courante
  card(40, cy, width - 80, 150);
  drawWeatherIcon(110, cy + 75, 90, weather.weatherCode);
  textFont(fontBold); textSize(42); fill(cText()); textAlign(LEFT, CENTER);
  text(nf(weather.temperature,0,1) + "°C", 190, cy + 60);
  textFont(fontReg); textSize(15); fill(120);
  text(weatherLabel(weather.weatherCode), 190, cy + 95);

  String[] labels = {"Humidité","Vent","Pression","Pluie","UV","Visibilité"};
  String[] vals = {
    round(weather.humidity) + "%",
    nf(weather.wind,0,1) + " km/h",
    round(weather.pressure) + " hPa",
    nf(weather.rain,0,1) + " mm",
    "" + weather.uv,
    nf(weather.visibility,0,0) + " km"
  };
  float sx = 560, sw = (width - 80 - 520) / 3.0;
  for (int i = 0; i < 6; i++) {
    float px = sx + (i % 3) * sw;
    float py = cy + 35 + (i / 3) * 60;
    textFont(fontBold); textSize(14); fill(cText()); textAlign(CENTER, CENTER);
    text(vals[i], px + sw/2, py);
    fill(150); textFont(fontReg); textSize(10);
    text(labels[i], px + sw/2, py + 18);
  }

  // Prévisions 7 jours
  float fy = cy + 170;
  card(40, fy, width - 80, 190);
  fill(cText()); textFont(fontBold); textSize(15); textAlign(LEFT, TOP);
  text("Prévisions sur 7 jours", 60, fy + 18);

  int n = weather.forecast.length;
  float availW = width - 80 - 40;
  float cw = availW / (float) n;
  for (int i = 0; i < n; i++) {
    DayForecast d = weather.forecast[i];
    float px = 60 + i * cw;
    float py = fy + 50;
    fill(249,250,251); noStroke(); rect(px, py, cw - 8, 120, 10);
    fill(90); textFont(fontReg); textSize(11); textAlign(CENTER, TOP);
    text(frDayName(d.date), px + (cw-8)/2, py + 8);
    drawWeatherIcon(px + (cw-8)/2, py + 44, 36, d.code);
    fill(cText()); textFont(fontBold); textSize(13); textAlign(CENTER, TOP);
    text(round(d.tmax) + "°", px + (cw-8)/2, py + 68);
    fill(150); textFont(fontReg); textSize(11);
    text(round(d.tmin) + "°", px + (cw-8)/2, py + 86);
    fill(59,130,246); textFont(fontBold); textSize(11);
    text(d.rainPct + "%", px + (cw-8)/2, py + 102);
  }

  // Détails
  float dy = fy + 210;
  card(40, dy, width - 80, 130);
  fill(cText()); textFont(fontBold); textSize(15); textAlign(LEFT, TOP);
  text("Détails aujourd'hui", 60, dy + 18);

  String[] dLabels = {"Humidité","Vent","Pression","Pluie","Indice UV","Visibilité"};
  String[] dVals = vals;
  color[] dBg = {color(239,246,255), color(236,254,255), color(250,245,255), color(239,246,255), color(254,252,232), color(240,253,244)};
  color[] dFg = {cBlue(), cCyan(), cPurple(), color(96,165,250), cYellow(), cGreen()};
  float dw = (width - 80 - 40 - 5*12) / 6.0;
  for (int i = 0; i < 6; i++) {
    float px = 60 + i * (dw + 12);
    float py = dy + 46;
    fill(dBg[i]); noStroke(); rect(px, py, dw, 56, 10);
    fill(dFg[i]); textFont(fontBold); textSize(13); textAlign(CENTER, TOP);
    text(dVals[i], px + dw/2, py + 12);
    fill(90); textFont(fontReg); textSize(9);
    text(dLabels[i], px + dw/2, py + 32);
  }

  fill(150); textFont(fontReg); textSize(10); textAlign(CENTER, CENTER);
  text("Source : Open-Meteo API · Mise à jour en temps réel", width/2, dy + 118);
}
