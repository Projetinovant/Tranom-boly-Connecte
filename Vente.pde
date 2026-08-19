class Marche {
  String initiale, nom, type, adresse, phone, whatsapp;
  float lat, lon;
  int prix;
  color c, bg;
  Marche(String i, String n, String t, String a, float lat, float lon, int p, String ph, String wa, color c, color bg) {
    initiale = i; nom = n; type = t; adresse = a; this.lat = lat; this.lon = lon; prix = p;
    phone = ph; whatsapp = wa; this.c = c; this.bg = bg;
  }
  float distanceKm() { return haversineKm(userLat, userLon, lat, lon); }
}

ArrayList<Marche> marches = new ArrayList<Marche>();
String[] venteFilters = {"Tous","Marches","Cooperatives","Grossistes","Exportateurs","Acheteurs"};
String venteActiveFilter = "Tous";
boolean venteNearMe = false;
Marche venteSelected = null;
TField tfVenteSearch;

boolean showMarcheModal = false;
int marcheEditIndex = -1;
TField tfMNom, tfMType, tfMAdresse, tfMPrix, tfMPhone, tfMWhatsapp, tfMLat, tfMLon;

color typeColor(String type) {
  if (type.equals("Marche")) return cGreen();
  if (type.equals("Cooperative")) return cBlue();
  if (type.equals("Grossiste")) return cOrange();
  if (type.equals("Exportateur")) return cPurple();
  return cRed();
}
color typeBg(String type) {
  if (type.equals("Marche")) return color(220,252,231);
  if (type.equals("Cooperative")) return color(219,234,254);
  if (type.equals("Grossiste")) return color(255,237,213);
  if (type.equals("Exportateur")) return color(243,232,255);
  return color(254,226,226);
}

void initVenteData() {
  tfVenteSearch = new TField(0,0,300,40,"","Rechercher un marche, acheteur, cooperative...");
  tfMNom = new TField(0,0,300,36,"Nom *","Ex: Marche X");
  tfMType = new TField(0,0,300,36,"Type * (Marche/Cooperative/Grossiste/Exportateur/Acheteur)","Ex: Marche");
  tfMAdresse = new TField(0,0,300,36,"Adresse *","Ex: Analakely, Antananarivo");
  tfMPrix = new TField(0,0,300,36,"Prix moyen (Ar/kg) *","Ex: 2600"); tfMPrix.numeric = true;
  tfMPhone = new TField(0,0,300,36,"Telephone *","+261 xx xx xxx xx");
  tfMWhatsapp = new TField(0,0,300,36,"WhatsApp (optionnel)","+261 xx xx xxx xx");
  tfMLat = new TField(0,0,140,36,"Latitude *","-18.91"); tfMLat.numeric = true;
  tfMLon = new TField(0,0,140,36,"Longitude *","47.52"); tfMLon.numeric = true;

  loadMarches();
  if (marches.isEmpty()) {
    marches.add(new Marche("M","Marche Analakely","Marche","Analakely, Antananarivo", -18.9086,47.5254, 2600,"+261 20 22 111 11","+261 32 00 111 11", typeColor("Marche"), typeBg("Marche")));
    marches.add(new Marche("C","Cooperative Fanantenana","Cooperative","Ambohidratrimo", -18.7710,47.4283, 2600,"+261 20 22 222 22", "", typeColor("Cooperative"), typeBg("Cooperative")));
    marches.add(new Marche("S","Sarl Fresh Agro","Grossiste","Ivato", -18.7969,47.4788, 2900,"+261 20 22 333 33","+261 32 00 333 33", typeColor("Grossiste"), typeBg("Grossiste")));
    marches.add(new Marche("E","Export Mada Ltd","Exportateur","Zone Forello, Tanjombato", -18.9530,47.5100, 3100,"+261 20 22 444 44","+261 32 00 444 44", typeColor("Exportateur"), typeBg("Exportateur")));
    marches.add(new Marche("A","Acheteur direct","Acheteur","Ambatolampy", -19.3833,47.4333, 2400,"+261 20 22 555 55", "", typeColor("Acheteur"), typeBg("Acheteur")));
    marches.add(new Marche("M","Marche de Behoririka","Marche","Behoririka, Antananarivo", -18.9070,47.5220, 2500,"+261 20 22 666 66","+261 32 00 666 66", typeColor("Marche"), typeBg("Marche")));
    marches.add(new Marche("C","Coop Vert Espoir","Cooperative","Manjakandriana", -18.8167,47.8000, 2750,"+261 20 22 777 77", "", typeColor("Cooperative"), typeBg("Cooperative")));
    saveMarches();
  }
}

void loadMarches() {
  marches.clear();
  String[] lines = loadStrings("marches.csv");
  if (lines == null) return;
  for (String l : lines) {
    if (l.trim().length() == 0) continue;
    String[] p = l.split("\\|", -1);
    if (p.length >= 8) {
      try {
        String type = p[1];
        marches.add(new Marche(p[0].substring(0,1).toUpperCase(), p[0], type, p[2],
                     Float.parseFloat(p[3]), Float.parseFloat(p[4]), Integer.parseInt(p[5]),
                     p[6], p[7], typeColor(type), typeBg(type)));
      } catch (Exception e) {}
    }
  }
}

void saveMarches() {
  String[] out = new String[marches.size()];
  for (int i = 0; i < marches.size(); i++) {
    Marche m = marches.get(i);
    out[i] = m.nom + "|" + m.type + "|" + m.adresse + "|" + m.lat + "|" + m.lon + "|" + m.prix + "|" + m.phone + "|" + m.whatsapp;
  }
  saveStrings("data/marches.csv", out);
}

ArrayList<Marche> filteredMarches() {
  ArrayList<Marche> list = new ArrayList<Marche>();
  for (Marche m : marches) {
    boolean matchSearch = tfVenteSearch.value.length() == 0 ||
      m.nom.toLowerCase().contains(tfVenteSearch.value.toLowerCase()) ||
      m.adresse.toLowerCase().contains(tfVenteSearch.value.toLowerCase());
    boolean matchFilter = venteActiveFilter.equals("Tous") ||
      (venteActiveFilter.equals("Marches") && m.type.equals("Marche")) ||
      (venteActiveFilter.equals("Cooperatives") && m.type.equals("Cooperative")) ||
      (venteActiveFilter.equals("Grossistes") && m.type.equals("Grossiste")) ||
      (venteActiveFilter.equals("Exportateurs") && m.type.equals("Exportateur")) ||
      (venteActiveFilter.equals("Acheteurs") && m.type.equals("Acheteur"));
    if (matchSearch && matchFilter) list.add(m);
  }
  if (venteNearMe) list.sort((a,b) -> Float.compare(a.distanceKm(), b.distanceKm()));
  return list;
}

void drawVente() {
  float top = navH + 24;
  fill(cGreen());
  textFont(fontBig); textSize(22); textAlign(LEFT, TOP);
  text("Vente & Marches", 40, top);
  fill(140);
  textFont(fontReg); textSize(12);
  text("Trouvez les meilleurs endroits pour vendre vos produits.", 40, top + 28);
  fill(geoReal ? cGreen() : color(190)); textSize(9); textAlign(RIGHT, TOP);
  text(geoLoading ? "Localisation en cours..." : (geoReal ? "Position reelle detectee (IP)" : "Position par defaut (geoloc indisponible)"), width - 40, top + 4);

  float sy = top + 56;
  card(40, sy, width - 80, 110);
  tfVenteSearch.x = 56; tfVenteSearch.y = sy + 16; tfVenteSearch.w = width - 80 - 380; tfVenteSearch.h = 40;
  tfVenteSearch.draw();
  button(width - 40 - 320, sy + 16, 150, 40, venteNearMe ? "Tri active" : "Autour de moi", venteNearMe);
  button(width - 40 - 160, sy + 16, 160, 40, "+ Ajouter un marche", true);

  float fx = 56;
  for (String f : venteFilters) {
    textFont(fontReg); textSize(12);
    float fw = textWidth(f) + 28;
    fill(venteActiveFilter.equals(f) ? cGreen() : color(245));
    noStroke(); rect(fx, sy + 70, fw, 28, 14);
    fill(venteActiveFilter.equals(f) ? 255 : 90);
    textAlign(CENTER, CENTER);
    text(f, fx + fw/2, sy + 84);
    fx += fw + 8;
  }

  float ty = sy + 126;
  ArrayList<Marche> list = filteredMarches();
  float listH = 40 + list.size() * 44 + 30;
  card(40, ty, width - 80, listH);
  fill(140); textFont(fontReg); textSize(9); textAlign(LEFT, CENTER);
  float headY = ty + 20;
  text("NOM", 90, headY);
  text("TYPE", 300, headY);
  text("ADRESSE", 420, headY);
  textAlign(RIGHT, CENTER);
  text("DISTANCE", width - 380, headY);
  text("PRIX MOYEN", width - 250, headY);
  text("CONTACT", width - 130, headY);
  text("ACTIONS", width - 40, headY);

  float ry = ty + 44;
  for (Marche m : list) {
    fill(m.bg); noStroke(); ellipse(70, ry + 14, 26, 26);
    fill(m.c); textFont(fontBold); textSize(11); textAlign(CENTER, CENTER);
    text(m.initiale, 70, ry + 14);
    fill(cText()); textFont(fontReg); textSize(11); textAlign(LEFT, CENTER);
    text(m.nom, 90, ry + 14, 200, 20);
    fill(m.c); text(m.type, 300, ry + 14);
    fill(90); text(m.adresse, 420, ry + 14, 200, 20);
    fill(90); textAlign(RIGHT, CENTER);
    text(nf(m.distanceKm(),0,1) + " km", width - 380, ry + 14);
    fill(cText()); textFont(fontBold);
    text(m.prix + " Ar/kg", width - 250, ry + 14);
    fill(m == venteSelected ? cGreen() : cGrayLight());
    textFont(fontReg); textSize(9);
    text("Tel / WhatsApp", width - 130, ry + 14);
    fill(cBlue()); textSize(9); textAlign(RIGHT, CENTER);
    text("Editer", width - 62, ry + 14);
    fill(cRed());
    text("Suppr.", width - 20, ry + 14);
    ry += 44;
  }

  float detY = ty + listH + 12;
  if (venteSelected != null) {
    fill(cGreenBg()); noStroke(); rect(40, detY, width - 80, 90, 14);
    fill(cText()); textFont(fontBold); textSize(13); textAlign(LEFT, TOP);
    text(venteSelected.nom, 56, detY + 14);
    fill(100); textFont(fontReg); textSize(10);
    text(venteSelected.adresse + " - " + nf(venteSelected.distanceKm(),0,1) + " km - " + venteSelected.prix + " Ar/kg", 56, detY + 32);
    text("Tel : " + venteSelected.phone, 56, detY + 48);
    button(width - 260, detY + 20, 100, 34, "Appeler", true);
    if (venteSelected.whatsapp != null && venteSelected.whatsapp.length() > 0) button(width - 150, detY + 20, 110, 34, "WhatsApp", false);
    detY += 100;
  } else {
    detY += 10;
  }

  fill(cGreenBg()); noStroke(); rect(40, detY, width - 80, 70, 14);
  fill(cGreenDark()); textFont(fontBold); textSize(13); textAlign(LEFT, TOP);
  text("Enregistrez vos ventes", 56, detY + 14);
  fill(cGreen()); textFont(fontReg); textSize(11);
  text("Suivez toutes vos transactions de vente au fil du temps.", 56, detY + 34);
  button(width - 200, detY + 16, 160, 38, "Mes ventes ->", true);

  if (showMarcheModal) drawMarcheModal();
}

void drawMarcheModal() {
  fill(0,0,0,100); noStroke(); rect(0, 0, width, height);
  float mx = width/2 - 210, my = height/2 - 260, mw = 420, mh = 500;
  fill(255); rect(mx, my, mw, mh, 16);
  fill(cText()); textFont(fontBold); textSize(15); textAlign(LEFT, TOP);
  text(marcheEditIndex >= 0 ? "Modifier le marche" : "Ajouter un marche", mx + 20, my + 16);

  float fy = my + 50;
  tfMNom.x = mx+20; tfMNom.y = fy; tfMNom.w = mw-40; tfMNom.h = 34; tfMNom.draw(); fy += 54;
  tfMType.x = mx+20; tfMType.y = fy; tfMType.w = mw-40; tfMType.h = 34; tfMType.draw(); fy += 54;
  tfMAdresse.x = mx+20; tfMAdresse.y = fy; tfMAdresse.w = mw-40; tfMAdresse.h = 34; tfMAdresse.draw(); fy += 54;
  tfMPrix.x = mx+20; tfMPrix.y = fy; tfMPrix.w = mw-40; tfMPrix.h = 34; tfMPrix.draw(); fy += 54;
  tfMPhone.x = mx+20; tfMPhone.y = fy; tfMPhone.w = mw-40; tfMPhone.h = 34; tfMPhone.draw(); fy += 54;
  tfMWhatsapp.x = mx+20; tfMWhatsapp.y = fy; tfMWhatsapp.w = mw-40; tfMWhatsapp.h = 34; tfMWhatsapp.draw(); fy += 54;
  tfMLat.x = mx+20; tfMLat.y = fy; tfMLat.w = (mw-52)/2; tfMLat.h = 34; tfMLat.draw();
  tfMLon.x = mx+32+(mw-52)/2; tfMLon.y = fy; tfMLon.w = (mw-52)/2; tfMLon.h = 34; tfMLon.draw();

  button(mx + 20, my + mh - 56, (mw - 52)/2, 40, "Annuler", false);
  button(mx + 32 + (mw - 52)/2, my + mh - 56, (mw - 52)/2, 40, "Enregistrer", true);
}

void openMarcheEdit(int idx) {
  marcheEditIndex = idx;
  if (idx >= 0) {
    Marche m = marches.get(idx);
    tfMNom.value = m.nom; tfMType.value = m.type; tfMAdresse.value = m.adresse;
    tfMPrix.value = "" + m.prix; tfMPhone.value = m.phone; tfMWhatsapp.value = m.whatsapp;
    tfMLat.value = "" + m.lat; tfMLon.value = "" + m.lon;
  } else {
    tfMNom.value = ""; tfMType.value = "Marche"; tfMAdresse.value = "";
    tfMPrix.value = ""; tfMPhone.value = ""; tfMWhatsapp.value = "";
    tfMLat.value = nf(userLat,0,4); tfMLon.value = nf(userLon,0,4);
  }
  showMarcheModal = true;
}

void venteMousePressed(float mx, float my) {
  float top = navH + 24, sy = top + 56;

  if (showMarcheModal) {
    tfMNom.focused = tfMNom.hit(mx,my); tfMType.focused = tfMType.hit(mx,my);
    tfMAdresse.focused = tfMAdresse.hit(mx,my); tfMPrix.focused = tfMPrix.hit(mx,my);
    tfMPhone.focused = tfMPhone.hit(mx,my); tfMWhatsapp.focused = tfMWhatsapp.hit(mx,my);
    tfMLat.focused = tfMLat.hit(mx,my); tfMLon.focused = tfMLon.hit(mx,my);

    float my0 = height/2 - 260, mmw = 420, mmh = 500, bx = width/2 - 210;
    if (clicked(bx+20, my0+mmh-56, (mmw-52)/2, 40, mx, my)) { showMarcheModal=false; return; }
    if (clicked(bx+32+(mmw-52)/2, my0+mmh-56, (mmw-52)/2, 40, mx, my)) {
      if (tfMNom.value.trim().length()>0 && tfMType.value.trim().length()>0 && tfMAdresse.value.trim().length()>0
          && tfMPrix.value.trim().length()>0 && tfMPhone.value.trim().length()>0
          && tfMLat.value.trim().length()>0 && tfMLon.value.trim().length()>0) {
        try {
          String type = tfMType.value.trim();
          Marche m = new Marche(tfMNom.value.trim().substring(0,1).toUpperCase(), tfMNom.value.trim(), type,
            tfMAdresse.value.trim(), Float.parseFloat(tfMLat.value), Float.parseFloat(tfMLon.value),
            Integer.parseInt(tfMPrix.value.trim()), tfMPhone.value.trim(), tfMWhatsapp.value.trim(),
            typeColor(type), typeBg(type));
          if (marcheEditIndex >= 0) { marches.set(marcheEditIndex, m); if (store!=null) store.addNotif("Marche modifie : " + m.nom); }
          else { marches.add(m); if (store!=null) store.addNotif("Nouveau marche ajoute : " + m.nom); }
          saveMarches();
        } catch (Exception e) {}
      }
      showMarcheModal = false;
      return;
    }
    return;
  }

  tfVenteSearch.focused = tfVenteSearch.hit(mx, my);
  if (clicked(width - 40 - 320, sy + 16, 150, 40, mx, my)) { venteNearMe = !venteNearMe; return; }
  if (clicked(width - 40 - 160, sy + 16, 160, 40, mx, my)) { openMarcheEdit(-1); return; }

  float fx = 56;
  for (String f : venteFilters) {
    textFont(fontReg); textSize(12);
    float fw = textWidth(f) + 28;
    if (clicked(fx, sy + 70, fw, 28, mx, my)) { venteActiveFilter = f; return; }
    fx += fw + 8;
  }

  float ty = sy + 126;
  ArrayList<Marche> list = filteredMarches();
  float listH = 40 + list.size() * 44 + 30;
  float ry = ty + 44;
  for (int i = 0; i < list.size(); i++) {
    Marche m = list.get(i);
    if (clicked(width - 90, ry - 10, 60, 24, mx, my)) {
      int realIdx = marches.indexOf(m);
      openMarcheEdit(realIdx);
      return;
    }
    if (clicked(width - 44, ry - 10, 44, 24, mx, my)) {
      marches.remove(m);
      saveMarches();
      if (store != null) store.addNotif("Marche supprime : " + m.nom);
      if (venteSelected == m) venteSelected = null;
      return;
    }
    if (clicked(40, ry - 10, width - 80, 44, mx, my)) {
      venteSelected = (venteSelected == m) ? null : m;
      return;
    }
    ry += 44;
  }

  float detY = ty + listH + 12;
  if (venteSelected != null) {
    if (clicked(width - 260, detY + 20, 100, 34, mx, my)) { link("tel:" + venteSelected.phone.replace(" ","")); return; }
    if (venteSelected.whatsapp != null && venteSelected.whatsapp.length()>0 && clicked(width - 150, detY + 20, 110, 34, mx, my)) {
      link("https://wa.me/" + venteSelected.whatsapp.replaceAll("\\s","").replace("+",""));
      return;
    }
    detY += 100;
  } else {
    detY += 10;
  }

  if (clicked(width - 200, detY + 16, 160, 38, mx, my)) { gotoScreen("ventesUser"); return; }
}

void venteKeyPressed() {
  if (showMarcheModal) {
    tfMNom.handleKey(); tfMType.handleKey(); tfMAdresse.handleKey(); tfMPrix.handleKey();
    tfMPhone.handleKey(); tfMWhatsapp.handleKey(); tfMLat.handleKey(); tfMLon.handleKey();
    return;
  }
  tfVenteSearch.handleKey();
}
