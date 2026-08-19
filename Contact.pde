// ---- Contact ----
TField tfNom, tfEmail, tfSujet;
String contactMessage = "";
boolean contactSent = false;
String contactError = "";
String contactStatusNote = "";
boolean focusMessage = false;
boolean contactSending = false;

void initContactFields() {
  tfNom   = new TField(0,0,300,40,"Nom complet *","Votre nom");
  tfEmail = new TField(0,0,300,40,"Email *","votre@email.com");
  tfSujet = new TField(0,0,300,40,"Sujet *","Objet de votre message");
}

boolean validEmail(String e) {
  return e.matches("^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$");
}

void drawContact() {
  float top = navH + 24;
  fill(cGreen());
  textFont(fontBig); textSize(22); textAlign(LEFT, TOP);
  text("Contactez-nous", 40, top);
  fill(140);
  textFont(fontReg); textSize(12);
  text("Nous sommes là pour vous aider.", 40, top + 28);

  float colw = (width - 80 - 32) / 2.0;
  float cy = top + 56;

  card(40, cy, colw, 260);
  fill(cText()); textFont(fontBold); textSize(14); textAlign(LEFT, TOP);
  text("Informations de contact", 56, cy + 16);
  String[][] infos = {
    {"Téléphone","+261 38 98 041 12"},
    {"WhatsApp","+261 38 98 041 12"},
    {"Email","jeremirichantossy@gmail.com"},
    {"Facebook","Tranom-boliko JGTech"},
    {"Adresse","Ankatso, Antananarivo, Madagascar"}
  };
  float iy = cy + 46;
  for (String[] info : infos) {
    fill(150); textFont(fontReg); textSize(9); textAlign(LEFT, TOP);
    text(info[0], 56, iy);
    fill(cText()); textFont(fontBold); textSize(12);
    text(info[1], 56, iy + 13);
    iy += 38;
  }

  float hy = cy + 270;
  card(40, hy, colw, 150);
  fill(cText()); textFont(fontBold); textSize(13); textAlign(LEFT, TOP);
  text("Heures d'ouverture", 56, hy + 14);

  java.util.Calendar cal = java.util.Calendar.getInstance();
  int dow = cal.get(java.util.Calendar.DAY_OF_WEEK);
  int h = hour();
  boolean isOpen = dow >= 2 && dow <= 6 && h >= 8 && h < 17;
  boolean isSatOpen = dow == 7 && h >= 8 && h < 12;
  String[][] sched = {{"Lundi – Vendredi","8h00 – 17h00"},{"Samedi","8h00 – 12h00"},{"Dimanche","Fermé"}};
  float sy2 = hy + 40;
  for (String[] s : sched) {
    fill(90); textFont(fontReg); textSize(11); textAlign(LEFT, CENTER);
    text(s[0], 56, sy2);
    fill(s[1].equals("Fermé") ? cRed() : cGreen()); textFont(fontBold);
    textAlign(RIGHT, CENTER);
    text(s[1], 40 + colw - 16, sy2);
    sy2 += 24;
  }
  boolean openNow = isOpen || isSatOpen;
  fill(openNow ? cGreenBg() : color(245));
  noStroke(); rect(56, hy + 120, colw - 32, 22, 8);
  fill(openNow ? cGreenDark() : color(120));
  textFont(fontReg); textSize(10); textAlign(CENTER, CENTER);
  text(openNow ? "Actuellement ouvert" : "Actuellement fermé", 56 + (colw-32)/2, hy + 131);

  float fx = 40 + colw + 32;
  card(fx, cy, colw, 420);
  fill(cText()); textFont(fontBold); textSize(14); textAlign(LEFT, TOP);
  text("Envoyez-nous un message", fx + 16, cy + 16);
  fill(smtpConfigured() ? cGreen() : color(190));
  textFont(fontReg); textSize(9); textAlign(RIGHT, TOP);
  text(smtpConfigured() ? "Envoi email réel activé" : "Envoi email réel non configuré (voir Aide)", fx + colw - 16, cy + 18);

  if (contactSent) {
    fill(cGreen()); noStroke(); ellipse(fx + colw/2, cy + 130, 60, 60);
    drawCheck(fx + colw/2, cy + 130, 26, color(255));
    fill(cText()); textFont(fontBold); textSize(14); textAlign(CENTER, TOP);
    text("Message enregistré !", fx + colw/2, cy + 175);
    fill(140); textFont(fontReg); textSize(11);
    text(contactStatusNote, fx + colw/2, cy + 198, colw - 40, 40);
    button(fx + colw/2 - 110, cy + 250, 220, 38, "Envoyer un autre message", false);
    return;
  }

  float formY = cy + 46;
  if (contactError.length() > 0) {
    fill(254,226,226); noStroke(); rect(fx + 16, formY, colw - 32, 30, 8);
    fill(cRed()); textFont(fontReg); textSize(10); textAlign(LEFT, CENTER);
    text(contactError, fx + 26, formY + 15);
    formY += 40;
  }

  tfNom.x = fx + 16;   tfNom.y = formY + 20;   tfNom.w = colw - 32; tfNom.h = 38;  tfNom.draw();
  tfEmail.x = fx + 16; tfEmail.y = formY + 80; tfEmail.w = colw - 32; tfEmail.h = 38; tfEmail.draw();
  tfSujet.x = fx + 16; tfSujet.y = formY + 140; tfSujet.w = colw - 32; tfSujet.h = 38; tfSujet.draw();

  fill(70); textFont(fontReg); textSize(12); textAlign(LEFT, BOTTOM);
  text("Votre message *", fx + 16, formY + 194);
  fill(255); stroke(focusMessage ? cGreen() : color(220));
  strokeWeight(focusMessage ? 2 : 1);
  rect(fx + 16, formY + 200, colw - 32, 90, 8);
  noStroke();
  fill(contactMessage.length() == 0 ? 180 : 30);
  textFont(fontReg); textSize(12); textAlign(LEFT, TOP);
  text(contactMessage.length() == 0 ? "Décrivez votre question ou problème..." : contactMessage,
       fx + 26, formY + 210, colw - 52, 80);

  button(fx + 16, formY + 304, colw - 32, 40, contactSending ? "Envoi en cours..." : "Envoyer le message", true);
}

void contactMousePressed(float mx, float my) {
  float top = navH + 24, colw = (width - 80 - 32) / 2.0, cy = top + 56, fx = 40 + colw + 32;

  if (contactSent) {
    if (clicked(fx + colw/2 - 110, cy + 250, 220, 38, mx, my)) {
      contactSent = false;
      tfNom.value = ""; tfEmail.value = ""; tfSujet.value = ""; contactMessage = "";
    }
    return;
  }

  float formY = cy + 46;
  if (contactError.length() > 0) formY += 40;

  tfNom.focused = tfNom.hit(mx, my);
  tfEmail.focused = tfEmail.hit(mx, my);
  tfSujet.focused = tfSujet.hit(mx, my);
  focusMessage = clicked(fx + 16, formY + 200, colw - 32, 90, mx, my);

  if (!contactSending && clicked(fx + 16, formY + 304, colw - 32, 40, mx, my)) {
    if (!validEmail(tfEmail.value.trim())) {
      contactError = "Veuillez entrer une adresse email valide.";
      return;
    }
    if (tfNom.value.trim().length() == 0 || tfSujet.value.trim().length() == 0 || contactMessage.trim().length() == 0) {
      contactError = "Veuillez remplir tous les champs obligatoires.";
      return;
    }
    contactError = "";
    if (store != null) {
      store.contacts.add(new ContactMsg(tfNom.value.trim(), tfEmail.value.trim(), tfSujet.value.trim(), contactMessage.trim()));
      store.addNotif("Message envoyé : " + tfSujet.value.trim());
    }
    if (smtpConfigured()) {
      contactSending = true;
      pendingContactName = tfNom.value.trim();
      pendingContactEmail = tfEmail.value.trim();
      pendingContactSubject = tfSujet.value.trim();
      pendingContactBody = contactMessage.trim();
      thread("sendContactEmailThread");
    } else {
      contactStatusNote = "Enregistré localement. Pour un envoi email réel, configurez data/smtp_config.txt (voir Aide).";
      contactSent = true;
    }
  }
}

String pendingContactName, pendingContactEmail, pendingContactSubject, pendingContactBody;

void sendContactEmailThread() {
  String err = sendEmailReal("jeremirichantossy@gmail.com", pendingContactName, pendingContactEmail,
                              pendingContactSubject, pendingContactBody);
  contactSending = false;
  if (err == null) {
    contactStatusNote = "Email envoyé avec succès à jeremirichantossy@gmail.com.";
  } else {
    contactStatusNote = "Enregistré localement. Envoi email échoué : " + err;
  }
  contactSent = true;
}

void contactKeyPressed() {
  tfNom.handleKey(); tfEmail.handleKey(); tfSujet.handleKey();
  if (focusMessage) {
    if (key == BACKSPACE) {
      if (contactMessage.length() > 0) contactMessage = contactMessage.substring(0, contactMessage.length() - 1);
    } else if (key == '\n' || key == '\r') {
      contactMessage += "\n";
    } else if (key != CODED) {
      contactMessage += key;
    }
  }
}
