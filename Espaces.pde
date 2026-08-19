// ---- Espaces utilisateurs (CRUD complet : ajout, edition, suppression) ----
boolean showTaskModal = false, showDepModal = false;
int taskEditIndex = -1, depEditIndex = -1;
TField tfTaskTitle;
String taskPriority = "normal";
TField tfDepLibelle, tfDepMontant, tfDepDate;

void initEspacesFields() {
  tfTaskTitle  = new TField(0,0,300,40,"Titre de la tache","Ex: Arroser les semis...");
  tfDepLibelle = new TField(0,0,300,40,"Libelle","Ex: Semences, Engrais...");
  tfDepMontant = new TField(0,0,300,40,"Montant (Ar)","Ex: 85000");
  tfDepMontant.numeric = true;
  tfDepDate    = new TField(0,0,300,40,"Date (AAAA-MM-JJ)", today());
}

void drawEspaces() {
  float top = navH + 24;
  fill(cGreen());
  textFont(fontBig); textSize(22); textAlign(LEFT, TOP);
  text("Espaces utilisateurs", 40, top);
  fill(140);
  textFont(fontReg); textSize(12);
  text("Gerez vos activites, depenses, benefices et recoltes.", 40, top + 28);

  int pending = 0;
  for (Task t : store.tasks) if (!t.done) pending++;
  double totalDep = 0;
  for (Depense d : store.depenses) totalDep += d.montant;
  double totalRec = 0, totalVal = 0;
  for (Recolte r : store.recoltes) { totalRec += r.qteKg; totalVal += r.valeurAr; }
  double benefice = totalVal - totalDep;

  float gy = top + 56;
  String[] labs = {"Taches a faire","Depenses","Benefices","Quantite recolte"};
  String[] subs = {"Taches en attente","Total ce mois","Benefice estime","Estimation totale"};
  String[] vals = {"" + pending, formatAr(totalDep), formatAr(benefice), nf((float) totalRec,0,0) + " kg"};
  float gw = (width - 80 - 3*12) / 4.0;
  for (int i = 0; i < 4; i++) {
    float px = 40 + i * (gw + 12);
    card(px, gy, gw, 90);
    fill(cText());
    textFont(fontBold); textSize(18); textAlign(LEFT, TOP);
    text(vals[i], px + 14, gy + 28);
    fill(150);
    textFont(fontReg); textSize(10);
    text(subs[i], px + 14, gy + 56);
    fill(90); textSize(10);
    text(labs[i], px + 14, gy + 70);
    if (i == 3) {
      fill(cGreen()); textSize(9); textAlign(RIGHT, TOP);
      text("Voir mes recoltes ->", px + gw - 10, gy + 8);
    }
  }

  float ty = gy + 110;
  float colw = (width - 80 - 16) / 2.0;

  // Taches
  card(40, ty, colw, 260);
  fill(cText());
  textFont(fontBold); textSize(14); textAlign(LEFT, TOP);
  text("Taches a faire", 56, ty + 16);
  button(40 + colw - 100, ty + 10, 84, 26, "+ Nouvelle", false);
  float ry = ty + 56;
  if (store.tasks.isEmpty()) {
    fill(170); textAlign(CENTER, CENTER); textSize(11);
    text("Aucune tache. Ajoutez-en une !", 40 + colw/2, ty + 130);
  }
  for (int i = 0; i < store.tasks.size() && i < 6; i++) {
    Task t = store.tasks.get(i);
    if (t.done) {
      fill(cGreen()); noStroke(); ellipse(56, ry + 6, 14, 14);
      drawCheck(56, ry + 6, 8, color(255));
    } else {
      noFill(); stroke(200); ellipse(56, ry + 6, 14, 14); noStroke();
    }
    fill(t.done ? color(160) : cText());
    textFont(fontReg); textSize(11); textAlign(LEFT, CENTER);
    text(t.title, 76, ry + 6, colw - 170, 20);
    if (t.priority.equals("urgent")) {
      fill(cOrange()); textAlign(RIGHT, CENTER); textSize(9);
      text("Urgent", 40 + colw - 78, ry + 6);
    }
    fill(cBlue()); textAlign(RIGHT, CENTER); textSize(10);
    text("Editer", 40 + colw - 38, ry + 6);
    fill(cRed());
    text("X", 40 + colw - 12, ry + 6);
    ry += 30;
  }

  // Depenses
  float dx = 40 + colw + 16;
  card(dx, ty, colw, 260);
  fill(cText());
  textFont(fontBold); textSize(14); textAlign(LEFT, TOP);
  text("Depenses recentes", dx + 16, ty + 16);
  button(dx + colw - 100, ty + 10, 84, 26, "+ Ajouter", false);
  float dry = ty + 56;
  if (store.depenses.isEmpty()) {
    fill(170); textAlign(CENTER, CENTER); textSize(11);
    text("Aucune depense enregistree.", dx + colw/2, ty + 130);
  }
  for (int i = 0; i < store.depenses.size() && i < 6; i++) {
    Depense d = store.depenses.get(i);
    fill(80); textFont(fontReg); textSize(11); textAlign(LEFT, CENTER);
    text(d.libelle, dx + 16, dry + 6, colw - 220, 20);
    fill(cRed()); textAlign(RIGHT, CENTER);
    text(formatAr(d.montant), dx + colw - 130, dry + 6);
    fill(160); textSize(9);
    text(d.date, dx + colw - 56, dry + 6);
    fill(cRed()); textSize(10);
    text("X", dx + colw - 12, dry + 6);
    dry += 28;
  }

  // Recoltes (resume)
  float rY = ty + 276;
  card(40, rY, width - 80, 100);
  fill(cText());
  textFont(fontBold); textSize(14); textAlign(LEFT, TOP);
  text("Recoltes par parcelle", 56, rY + 16);
  fill(90); textFont(fontReg); textSize(11);
  text(store.recoltes.size() + " recolte(s) enregistree(s) - " + nf((float) totalRec,0,0) + " kg - " + formatAr(totalVal), 56, rY + 42);
  button(width - 220, rY + 30, 160, 38, "Gerer mes recoltes ->", true);

  if (showTaskModal) drawTaskModal();
  if (showDepModal) drawDepModal();
}

void drawTaskModal() {
  fill(0,0,0,100); noStroke(); rect(0, 0, width, height);
  float mx = width/2 - 190, my = height/2 - 160, mw = 380, mh = 300;
  fill(255); rect(mx, my, mw, mh, 16);
  fill(cText()); textFont(fontBold); textSize(15); textAlign(LEFT, TOP);
  text(taskEditIndex >= 0 ? "Modifier la tache" : "Nouvelle tache", mx + 20, my + 18);

  tfTaskTitle.x = mx + 20; tfTaskTitle.y = my + 60; tfTaskTitle.w = mw - 40; tfTaskTitle.h = 40;
  tfTaskTitle.draw();

  fill(70); textFont(fontReg); textSize(12); textAlign(LEFT, BOTTOM);
  text("Priorite", mx + 20, my + 128);
  String[] opts = {"normal","urgent"};
  String[] optsLabel = {"Normal","Urgent"};
  for (int i = 0; i < 2; i++) {
    float ox = mx + 20 + i * 100;
    fill(taskPriority.equals(opts[i]) ? cGreen() : 255);
    stroke(cBorder()); rect(ox, my + 134, 90, 32, 8); noStroke();
    fill(taskPriority.equals(opts[i]) ? 255 : 80);
    textAlign(CENTER, CENTER);
    text(optsLabel[i], ox + 45, my + 150);
  }

  button(mx + 20, my + mh - 56, (mw - 52)/2, 40, "Annuler", false);
  button(mx + 32 + (mw - 52)/2, my + mh - 56, (mw - 52)/2, 40, taskEditIndex >= 0 ? "Enregistrer" : "Ajouter", true);
}

void drawDepModal() {
  fill(0,0,0,100); noStroke(); rect(0, 0, width, height);
  float mx = width/2 - 190, my = height/2 - 190, mw = 380, mh = 360;
  fill(255); rect(mx, my, mw, mh, 16);
  fill(cText()); textFont(fontBold); textSize(15); textAlign(LEFT, TOP);
  text(depEditIndex >= 0 ? "Modifier la depense" : "Nouvelle depense", mx + 20, my + 18);

  tfDepLibelle.x = mx + 20; tfDepLibelle.y = my + 60;  tfDepLibelle.w = mw - 40; tfDepLibelle.h = 40; tfDepLibelle.draw();
  tfDepMontant.x = mx + 20; tfDepMontant.y = my + 130; tfDepMontant.w = mw - 40; tfDepMontant.h = 40; tfDepMontant.draw();
  tfDepDate.x    = mx + 20; tfDepDate.y    = my + 200; tfDepDate.w    = mw - 40; tfDepDate.h    = 40; tfDepDate.draw();

  button(mx + 20, my + mh - 56, (mw - 52)/2, 40, "Annuler", false);
  button(mx + 32 + (mw - 52)/2, my + mh - 56, (mw - 52)/2, 40, depEditIndex >= 0 ? "Enregistrer" : "Ajouter", true);
}

void openTaskEdit(int idx) {
  taskEditIndex = idx;
  if (idx >= 0) {
    Task t = store.tasks.get(idx);
    tfTaskTitle.value = t.title; taskPriority = t.priority;
  } else {
    tfTaskTitle.value = ""; taskPriority = "normal";
  }
  showTaskModal = true;
}

void openDepEdit(int idx) {
  depEditIndex = idx;
  if (idx >= 0) {
    Depense d = store.depenses.get(idx);
    tfDepLibelle.value = d.libelle; tfDepMontant.value = nf((float) d.montant,0,0); tfDepDate.value = d.date;
  } else {
    tfDepLibelle.value = ""; tfDepMontant.value = ""; tfDepDate.value = today();
  }
  showDepModal = true;
}

void espacesMousePressed(float mx, float my) {
  if (showTaskModal) {
    tfTaskTitle.focused = tfTaskTitle.hit(mx, my);
    float my0 = height/2 - 160, mmw = 380, mmh = 300;
    float bx = width/2 - 190;
    if (clicked(bx + 20, my0 + 134, 90, 32, mx, my)) taskPriority = "normal";
    if (clicked(bx + 120, my0 + 134, 90, 32, mx, my)) taskPriority = "urgent";
    if (clicked(bx + 20, my0 + mmh - 56, (mmw - 52)/2, 40, mx, my)) { showTaskModal = false; return; }
    if (clicked(bx + 32 + (mmw - 52)/2, my0 + mmh - 56, (mmw - 52)/2, 40, mx, my)) {
      if (tfTaskTitle.value.trim().length() > 0) {
        if (taskEditIndex >= 0) {
          Task t = store.tasks.get(taskEditIndex);
          t.title = tfTaskTitle.value.trim(); t.priority = taskPriority;
          store.addNotif("Tache modifiee : " + t.title);
        } else {
          store.tasks.add(0, new Task(tfTaskTitle.value.trim(), taskPriority, false));
          store.addNotif("Nouvelle tache : " + tfTaskTitle.value.trim());
        }
        store.saveTasks();
        envoyerTachesVersEsp32();
      }
      tfTaskTitle.value = ""; taskPriority = "normal"; showTaskModal = false;
      return;
    }
    return;
  }

  if (showDepModal) {
    tfDepLibelle.focused = tfDepLibelle.hit(mx, my);
    tfDepMontant.focused = tfDepMontant.hit(mx, my);
    tfDepDate.focused    = tfDepDate.hit(mx, my);
    float my0 = height/2 - 190, mmw = 380, mmh = 360;
    float bx = width/2 - 190;
    if (clicked(bx + 20, my0 + mmh - 56, (mmw - 52)/2, 40, mx, my)) { showDepModal = false; return; }
    if (clicked(bx + 32 + (mmw - 52)/2, my0 + mmh - 56, (mmw - 52)/2, 40, mx, my)) {
      if (tfDepLibelle.value.trim().length() > 0 && tfDepMontant.value.trim().length() > 0) {
        double m = 0;
        try { m = Double.parseDouble(tfDepMontant.value); } catch (Exception e) {}
        String dt = tfDepDate.value.trim().length() > 0 ? tfDepDate.value.trim() : today();
        if (depEditIndex >= 0) {
          Depense d = store.depenses.get(depEditIndex);
          d.libelle = tfDepLibelle.value.trim(); d.montant = m; d.date = dt;
          store.addNotif("Depense modifiee : " + d.libelle);
        } else {
          store.depenses.add(0, new Depense(tfDepLibelle.value.trim(), m, dt));
          store.addNotif("Nouvelle depense : " + tfDepLibelle.value.trim());
        }
        store.saveDepenses();
      }
      tfDepLibelle.value = ""; tfDepMontant.value = ""; tfDepDate.value = today();
      showDepModal = false;
      return;
    }
    return;
  }

  float top = navH + 24, gy = top + 56, ty = gy + 110;
  float colw = (width - 80 - 16) / 2.0;
  float gw = (width - 80 - 3*12) / 4.0;

  if (clicked(40 + 3*(gw+12), gy, gw, 90, mx, my)) { gotoScreen("recoltes"); return; }
  if (clicked(40 + colw - 100, ty + 10, 84, 26, mx, my)) { openTaskEdit(-1); return; }
  if (clicked(40 + colw + 16 + colw - 100, ty + 10, 84, 26, mx, my)) { openDepEdit(-1); return; }

  float ry = ty + 56;
  for (int i = 0; i < store.tasks.size() && i < 6; i++) {
    if (clicked(40 + colw - 50, ry - 8, 30, 16, mx, my)) { openTaskEdit(i); return; }
    if (clicked(40 + colw - 20, ry - 8, 16, 16, mx, my)) {
      Task t = store.tasks.get(i);
      store.deleteTask(i);
      store.addNotif("Tache supprimee : " + t.title);
      envoyerTachesVersEsp32();
      return;
    }
    if (dist(mx, my, 56, ry + 6) < 10) {
      Task t = store.tasks.get(i);
      t.done = !t.done;
      store.saveTasks();
      envoyerTachesVersEsp32();
      return;
    }
    ry += 30;
  }

  float dx = 40 + colw + 16;
  float dry = ty + 56;
  for (int i = 0; i < store.depenses.size() && i < 6; i++) {
    if (clicked(dx + colw - 20, dry - 8, 16, 16, mx, my)) {
      Depense d = store.depenses.get(i);
      store.deleteDepense(i);
      store.addNotif("Depense supprimee : " + d.libelle);
      return;
    }
    dry += 28;
  }

  float rY = ty + 276;
  if (clicked(width - 220, rY + 30, 160, 38, mx, my)) { gotoScreen("recoltes"); return; }
}

void espacesKeyPressed() {
  if (showTaskModal) tfTaskTitle.handleKey();
  if (showDepModal) { tfDepLibelle.handleKey(); tfDepMontant.handleKey(); tfDepDate.handleKey(); }
}
