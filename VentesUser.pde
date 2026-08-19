// ---- Mes ventes (CRUD complet) ----
boolean showVenteModal = false;
int venteEditIndex = -1;
TField tfVCulture, tfVQte, tfVPrix, tfVAcheteur, tfVDate;

void initVentesUserFields() {
  tfVCulture  = new TField(0,0,300,40,"Culture *","Ex: Tomates");
  tfVQte      = new TField(0,0,140,40,"Quantite (kg) *","Ex: 100"); tfVQte.numeric = true;
  tfVPrix     = new TField(0,0,140,40,"Prix/kg (Ar) *","Ex: 2600"); tfVPrix.numeric = true;
  tfVAcheteur = new TField(0,0,300,40,"Acheteur / Marche","Ex: Marche Analakely");
  tfVDate     = new TField(0,0,300,40,"Date *", today());
}

void drawVentesUser() {
  float top = navH + 24;
  button(40, top, 90, 30, "<- Retour", false);
  fill(cGreen());
  textFont(fontBig); textSize(22); textAlign(LEFT, TOP);
  text("Mes ventes", 40, top + 44);
  fill(140);
  textFont(fontReg); textSize(12);
  text("Suivez vos ventes et transactions.", 40, top + 70);
  button(width - 220, top + 40, 180, 40, "+ Nouvelle vente", true);

  double total = 0;
  for (VenteItem v : store.ventes) total += v.montantTotal;

  float sy = top + 100;
  float cw = (width - 80 - 16) / 2.0;
  card(40, sy, cw, 70);
  fill(cGreen()); textFont(fontBold); textSize(20); textAlign(CENTER, CENTER);
  text("" + store.ventes.size(), 40 + cw/2, sy + 26);
  fill(150); textFont(fontReg); textSize(10);
  text("Ventes enregistrees", 40 + cw/2, sy + 48);

  card(40 + cw + 16, sy, cw, 70);
  fill(cGreenDark()); textFont(fontBold); textSize(18); textAlign(CENTER, CENTER);
  text(formatAr(total), 40 + cw + 16 + cw/2, sy + 26);
  fill(150); textFont(fontReg); textSize(10);
  text("Revenus totaux", 40 + cw + 16 + cw/2, sy + 48);

  float ty = sy + 90;
  float listH = store.ventes.isEmpty() ? 90 : (40 + store.ventes.size() * 30 + 20);
  card(40, ty, width - 80, listH);

  if (store.ventes.isEmpty()) {
    fill(170); textAlign(CENTER, CENTER); textSize(12);
    text("Aucune vente enregistree.", width/2, ty + 50);
  } else {
    fill(140); textFont(fontReg); textSize(9); textAlign(LEFT, CENTER);
    float hy = ty + 18;
    text("CULTURE", 56, hy);
    textAlign(RIGHT, CENTER);
    text("QTE (KG)", 300, hy);
    text("PRIX/KG", 400, hy);
    text("TOTAL", 540, hy);
    textAlign(LEFT, CENTER);
    text("ACHETEUR", 570, hy);
    textAlign(RIGHT, CENTER);
    text("DATE", width - 140, hy);
    text("ACTIONS", width - 40, hy);

    float ry = ty + 40;
    for (int i = 0; i < store.ventes.size(); i++) {
      VenteItem v = store.ventes.get(i);
      fill(60); textFont(fontReg); textSize(11); textAlign(LEFT, CENTER);
      text(v.culture, 56, ry);
      textAlign(RIGHT, CENTER);
      text(nf((float) v.qteKg,0,0), 300, ry);
      text(round(v.prixKg) + " Ar", 400, ry);
      fill(cGreen()); textFont(fontBold);
      text(formatAr(v.montantTotal), 540, ry);
      fill(90); textFont(fontReg); textAlign(LEFT, CENTER);
      text(v.acheteur.length() > 0 ? v.acheteur : "-", 570, ry, 200, 20);
      fill(160); textAlign(RIGHT, CENTER);
      text(v.date, width - 140, ry);
      fill(cBlue()); textSize(10);
      text("Editer", width - 78, ry);
      fill(cRed());
      text("Suppr.", width - 28, ry);
      ry += 30;
    }
  }

  if (showVenteModal) drawVenteModal();
}

void drawVenteModal() {
  fill(0,0,0,100); noStroke(); rect(0, 0, width, height);
  float mx = width/2 - 200, my = height/2 - 220, mw = 400, mh = 440;
  fill(255); rect(mx, my, mw, mh, 16);
  fill(cText()); textFont(fontBold); textSize(15); textAlign(LEFT, TOP);
  text(venteEditIndex >= 0 ? "Modifier la vente" : "Nouvelle vente", mx + 20, my + 18);

  tfVCulture.x = mx + 20; tfVCulture.y = my + 56;  tfVCulture.w = mw - 40; tfVCulture.h = 38; tfVCulture.draw();
  tfVQte.x = mx + 20;              tfVQte.y = my + 118;  tfVQte.w = (mw - 52)/2; tfVQte.h = 38;  tfVQte.draw();
  tfVPrix.x = mx + 32 + (mw-52)/2; tfVPrix.y = my + 118; tfVPrix.w = (mw - 52)/2; tfVPrix.h = 38; tfVPrix.draw();

  if (tfVQte.value.length() > 0 && tfVPrix.value.length() > 0) {
    try {
      double t = Double.parseDouble(tfVQte.value) * Double.parseDouble(tfVPrix.value);
      fill(220,252,231); noStroke(); rect(mx + 20, my + 168, mw - 40, 30, 8);
      fill(cGreenDark()); textFont(fontBold); textSize(11); textAlign(LEFT, CENTER);
      text("Total estime : " + formatAr(t), mx + 32, my + 183);
    } catch (Exception e) {}
  }

  tfVAcheteur.x = mx + 20; tfVAcheteur.y = my + 218; tfVAcheteur.w = mw - 40; tfVAcheteur.h = 38; tfVAcheteur.draw();
  tfVDate.x = mx + 20;     tfVDate.y = my + 280;     tfVDate.w = mw - 40;     tfVDate.h = 38;     tfVDate.draw();

  button(mx + 20, my + mh - 56, (mw - 52)/2, 40, "Annuler", false);
  button(mx + 32 + (mw - 52)/2, my + mh - 56, (mw - 52)/2, 40, venteEditIndex >= 0 ? "Enregistrer" : "Enregistrer", true);
}

void openVenteEdit(int idx) {
  venteEditIndex = idx;
  if (idx >= 0) {
    VenteItem v = store.ventes.get(idx);
    tfVCulture.value = v.culture; tfVQte.value = nf((float) v.qteKg,0,0);
    tfVPrix.value = nf((float) v.prixKg,0,0); tfVAcheteur.value = v.acheteur; tfVDate.value = v.date;
  } else {
    tfVCulture.value = ""; tfVQte.value = ""; tfVPrix.value = ""; tfVAcheteur.value = ""; tfVDate.value = today();
  }
  showVenteModal = true;
}

void ventesUserMousePressed(float mx, float my) {
  float top = navH + 24;
  if (!showVenteModal && clicked(40, top, 90, 30, mx, my)) { currentScreen = "vente"; return; }
  if (!showVenteModal && clicked(width - 220, top + 40, 180, 40, mx, my)) { openVenteEdit(-1); return; }

  if (showVenteModal) {
    tfVCulture.focused  = tfVCulture.hit(mx, my);
    tfVQte.focused      = tfVQte.hit(mx, my);
    tfVPrix.focused     = tfVPrix.hit(mx, my);
    tfVAcheteur.focused = tfVAcheteur.hit(mx, my);
    tfVDate.focused     = tfVDate.hit(mx, my);

    float my0 = height/2 - 220, mmw = 400, mmh = 440;
    float bx = width/2 - 200;
    if (clicked(bx + 20, my0 + mmh - 56, (mmw - 52)/2, 40, mx, my)) { showVenteModal = false; return; }
    if (clicked(bx + 32 + (mmw - 52)/2, my0 + mmh - 56, (mmw - 52)/2, 40, mx, my)) {
      if (tfVCulture.value.trim().length() > 0 && tfVQte.value.trim().length() > 0 && tfVPrix.value.trim().length() > 0) {
        try {
          float q = Float.parseFloat(tfVQte.value);
          float p = Float.parseFloat(tfVPrix.value);
          String dt = tfVDate.value.trim().length() > 0 ? tfVDate.value.trim() : today();
          VenteItem v = new VenteItem(tfVCulture.value.trim(), q, p, q * p, tfVAcheteur.value.trim(), dt);
          if (venteEditIndex >= 0) {
            store.ventes.set(venteEditIndex, v);
            store.addNotif("Vente modifiee : " + v.culture);
          } else {
            store.ventes.add(0, v);
            store.addNotif("Nouvelle vente : " + v.culture + " (" + formatAr(v.montantTotal) + ")");
          }
          store.saveVentes();
        } catch (Exception e) {}
      }
      tfVCulture.value = ""; tfVQte.value = ""; tfVPrix.value = ""; tfVAcheteur.value = ""; tfVDate.value = today();
      showVenteModal = false;
      return;
    }
    return;
  }

  float sy = top + 100, ty = sy + 90;
  float ry = ty + 40;
  for (int i = 0; i < store.ventes.size(); i++) {
    if (clicked(width - 108, ry - 10, 60, 20, mx, my)) { openVenteEdit(i); return; }
    if (clicked(width - 56, ry - 10, 50, 20, mx, my)) {
      VenteItem v = store.ventes.get(i);
      store.deleteVente(i);
      store.addNotif("Vente supprimee : " + v.culture);
      return;
    }
    ry += 30;
  }
}

void ventesUserKeyPressed() {
  if (showVenteModal) {
    tfVCulture.handleKey(); tfVQte.handleKey(); tfVPrix.handleKey(); tfVAcheteur.handleKey(); tfVDate.handleKey();
  }
}
