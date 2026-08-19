// ---- Récoltes (CRUD complet) ----
boolean showRecolteModal = false;
int recolteEditIndex = -1; // -1 = nouvelle récolte
TField tfRCulture, tfRParcelle, tfRQte, tfRValeur, tfRDate;

void initRecoltesFields() {
  tfRCulture  = new TField(0,0,300,38,"Culture *","Ex: Tomates");
  tfRParcelle = new TField(0,0,300,38,"Parcelle *","Ex: Parcelle A");
  tfRQte      = new TField(0,0,140,38,"Quantité (kg) *","Ex: 3000"); tfRQte.numeric = true;
  tfRValeur   = new TField(0,0,140,38,"Valeur estimée (Ar) *","Ex: 700000"); tfRValeur.numeric = true;
  tfRDate     = new TField(0,0,300,38,"Date *", today());
}

void drawRecoltes() {
  float top = navH + 24;
  button(40, top, 90, 30, "← Retour", false);
  fill(cGreen());
  textFont(fontBig); textSize(22); textAlign(LEFT, TOP);
  text("Mes récoltes", 40, top + 44);
  fill(140);
  textFont(fontReg); textSize(12);
  text("Ajoutez, modifiez ou supprimez vos récoltes par parcelle.", 40, top + 70);
  button(width - 220, top + 40, 180, 40, "+ Nouvelle récolte", true);

  double totalKg = 0, totalVal = 0;
  for (Recolte r : store.recoltes) { totalKg += r.qteKg; totalVal += r.valeurAr; }

  float sy = top + 100;
  float cw = (width - 80 - 16) / 2.0;
  card(40, sy, cw, 70);
  fill(cGreen()); textFont(fontBold); textSize(18); textAlign(CENTER, CENTER);
  text(nf((float) totalKg,0,0) + " kg", 40 + cw/2, sy + 26);
  fill(150); textFont(fontReg); textSize(10);
  text("Quantité totale", 40 + cw/2, sy + 48);

  card(40 + cw + 16, sy, cw, 70);
  fill(cGreenDark()); textFont(fontBold); textSize(18); textAlign(CENTER, CENTER);
  text(formatAr(totalVal), 40 + cw + 16 + cw/2, sy + 26);
  fill(150); textFont(fontReg); textSize(10);
  text("Valeur totale estimée", 40 + cw + 16 + cw/2, sy + 48);

  float ty = sy + 90;
  float listH = store.recoltes.isEmpty() ? 90 : (40 + store.recoltes.size() * 34 + 20);
  card(40, ty, width - 80, listH);

  if (store.recoltes.isEmpty()) {
    fill(170); textAlign(CENTER, CENTER); textSize(12);
    text("Aucune récolte enregistrée.", width/2, ty + 50);
  } else {
    fill(140); textFont(fontReg); textSize(9); textAlign(LEFT, CENTER);
    float hy = ty + 18;
    text("CULTURE", 56, hy);
    text("PARCELLE", 260, hy);
    textAlign(RIGHT, CENTER);
    text("QUANTITÉ", 560, hy);
    text("VALEUR", 700, hy);
    text("DATE", 820, hy);
    text("ACTIONS", width - 60, hy);

    float ry = ty + 40;
    for (int i = 0; i < store.recoltes.size(); i++) {
      Recolte r = store.recoltes.get(i);
      fill(60); textFont(fontReg); textSize(11); textAlign(LEFT, CENTER);
      text(r.culture, 56, ry);
      fill(cGreen());
      text(r.parcelle, 260, ry);
      fill(90); textAlign(RIGHT, CENTER);
      text(nf((float) r.qteKg,0,0) + " kg", 560, ry);
      fill(cGreen()); textFont(fontBold);
      text(formatAr(r.valeurAr), 700, ry);
      fill(160); textFont(fontReg);
      text(r.date, 820, ry);

      fill(cBlue()); textAlign(RIGHT, CENTER);
      text("Modifier", width - 110, ry);
      fill(cRed());
      text("Supprimer", width - 30, ry);
      ry += 34;
    }
  }

  if (showRecolteModal) drawRecolteModal();
}

void drawRecolteModal() {
  fill(0,0,0,100); noStroke(); rect(0, 0, width, height);
  float mx = width/2 - 200, my = height/2 - 220, mw = 400, mh = 400;
  fill(255); rect(mx, my, mw, mh, 16);
  fill(cText()); textFont(fontBold); textSize(15); textAlign(LEFT, TOP);
  text(recolteEditIndex >= 0 ? "Modifier la récolte" : "Nouvelle récolte", mx + 20, my + 18);

  tfRCulture.x = mx + 20;  tfRCulture.y = my + 56;  tfRCulture.w = mw - 40; tfRCulture.h = 38; tfRCulture.draw();
  tfRParcelle.x = mx + 20; tfRParcelle.y = my + 116; tfRParcelle.w = mw - 40; tfRParcelle.h = 38; tfRParcelle.draw();
  tfRQte.x = mx + 20;              tfRQte.y = my + 176; tfRQte.w = (mw-52)/2; tfRQte.h = 38; tfRQte.draw();
  tfRValeur.x = mx + 32 + (mw-52)/2; tfRValeur.y = my + 176; tfRValeur.w = (mw-52)/2; tfRValeur.h = 38; tfRValeur.draw();
  tfRDate.x = mx + 20; tfRDate.y = my + 236; tfRDate.w = mw - 40; tfRDate.h = 38; tfRDate.draw();

  button(mx + 20, my + mh - 56, (mw - 52)/2, 40, "Annuler", false);
  button(mx + 32 + (mw - 52)/2, my + mh - 56, (mw - 52)/2, 40, recolteEditIndex >= 0 ? "Enregistrer" : "Ajouter", true);
}

void openRecolteEdit(int idx) {
  recolteEditIndex = idx;
  if (idx >= 0) {
    Recolte r = store.recoltes.get(idx);
    tfRCulture.value = r.culture; tfRParcelle.value = r.parcelle;
    tfRQte.value = nf((float) r.qteKg,0,0); tfRValeur.value = nf((float) r.valeurAr,0,0);
    tfRDate.value = r.date;
  } else {
    tfRCulture.value = ""; tfRParcelle.value = ""; tfRQte.value = ""; tfRValeur.value = ""; tfRDate.value = today();
  }
  showRecolteModal = true;
}

void recoltesMousePressed(float mx, float my) {
  float top = navH + 24;
  if (!showRecolteModal && clicked(40, top, 90, 30, mx, my)) { currentScreen = "espaces"; return; }
  if (!showRecolteModal && clicked(width - 220, top + 40, 180, 40, mx, my)) { openRecolteEdit(-1); return; }

  if (showRecolteModal) {
    tfRCulture.focused = tfRCulture.hit(mx, my);
    tfRParcelle.focused = tfRParcelle.hit(mx, my);
    tfRQte.focused = tfRQte.hit(mx, my);
    tfRValeur.focused = tfRValeur.hit(mx, my);
    tfRDate.focused = tfRDate.hit(mx, my);

    float my0 = height/2 - 220, mmw = 400, mmh = 400;
    float bx = width/2 - 200;
    if (clicked(bx + 20, my0 + mmh - 56, (mmw - 52)/2, 40, mx, my)) { showRecolteModal = false; return; }
    if (clicked(bx + 32 + (mmw - 52)/2, my0 + mmh - 56, (mmw - 52)/2, 40, mx, my)) {
      if (tfRCulture.value.trim().length() > 0 && tfRParcelle.value.trim().length() > 0 &&
          tfRQte.value.trim().length() > 0 && tfRValeur.value.trim().length() > 0) {
        try {
          double q = Double.parseDouble(tfRQte.value);
          double v = Double.parseDouble(tfRValeur.value);
          String dt = tfRDate.value.trim().length() > 0 ? tfRDate.value.trim() : today();
          Recolte r = new Recolte(tfRCulture.value.trim(), tfRParcelle.value.trim(), q, v, dt);
          if (recolteEditIndex >= 0) {
            store.recoltes.set(recolteEditIndex, r);
            store.addNotif("Récolte modifiée : " + r.culture);
          } else {
            store.recoltes.add(0, r);
            store.addNotif("Nouvelle récolte : " + r.culture + " (" + nf((float)q,0,0) + " kg)");
          }
          store.saveRecoltes();
        } catch (Exception e) {}
      }
      showRecolteModal = false;
      return;
    }
    return;
  }

  float sy = top + 100, ty = sy + 90;
  float ry = ty + 40;
  for (int i = 0; i < store.recoltes.size(); i++) {
    if (clicked(width - 150, ry - 10, 80, 20, mx, my)) { openRecolteEdit(i); return; }
    if (clicked(width - 60, ry - 10, 60, 20, mx, my)) {
      Recolte r = store.recoltes.get(i);
      store.deleteRecolte(i);
      store.addNotif("Récolte supprimée : " + r.culture);
      return;
    }
    ry += 34;
  }
}

void recoltesKeyPressed() {
  if (showRecolteModal) {
    tfRCulture.handleKey(); tfRParcelle.handleKey(); tfRQte.handleKey(); tfRValeur.handleKey(); tfRDate.handleKey();
  }
}
