// ---- Écran de connexion / inscription ----
TField tfAuthUser, tfAuthPass, tfAuthPass2;
boolean authIsRegister = false;
String authError = "";
String authAfterLoginScreen = "accueil";

void initAuthFields() {
  tfAuthUser  = new TField(0,0,320,42,"Nom d'utilisateur","Ex: jeremi");
  tfAuthPass  = new TField(0,0,320,42,"Mot de passe","••••••••");
  tfAuthPass2 = new TField(0,0,320,42,"Confirmer le mot de passe","••••••••");
}

void drawLogin() {
  float cx = width/2, cy = height/2 - 140;
  float mw = 380;
  float mx = cx - mw/2;

  fill(cGreen());
  textFont(fontBig); textSize(24); textAlign(CENTER, TOP);
  text("Tranom-boliko", cx, cy - 60);
  fill(140); textFont(fontReg); textSize(12);
  text(authIsRegister ? "Créer un compte" : "Connexion à votre espace", cx, cy - 28);

  card(mx, cy, mw, authIsRegister ? 330 : 260);

  float fy = cy + 24;
  tfAuthUser.x = mx + 20; tfAuthUser.y = fy; tfAuthUser.w = mw - 40; tfAuthUser.h = 42; tfAuthUser.draw();
  fy += 66;
  tfAuthPass.x = mx + 20; tfAuthPass.y = fy; tfAuthPass.w = mw - 40; tfAuthPass.h = 42; tfAuthPass.draw();
  fy += 66;
  if (authIsRegister) {
    tfAuthPass2.x = mx + 20; tfAuthPass2.y = fy; tfAuthPass2.w = mw - 40; tfAuthPass2.h = 42; tfAuthPass2.draw();
    fy += 66;
  }

  if (authError.length() > 0) {
    fill(cRed()); textFont(fontReg); textSize(11); textAlign(CENTER, TOP);
    text(authError, cx, fy + 4);
    fy += 24;
  }

  button(mx + 20, fy + 10, mw - 40, 42, authIsRegister ? "Créer le compte" : "Se connecter", true);
  fill(cGreen()); textFont(fontReg); textSize(11); textAlign(CENTER, TOP);
  text(authIsRegister ? "J'ai déjà un compte — Se connecter" : "Pas de compte — S'inscrire", cx, fy + 62);

  fill(150); textFont(fontReg); textSize(10); textAlign(CENTER, TOP);
  text("Vos identifiants restent sur cet ordinateur (aucun serveur distant).", cx, cy + (authIsRegister?330:260) + 14);
}

void loginMousePressed(float mx0, float my0) {
  tfAuthUser.focused = tfAuthUser.hit(mx0, my0);
  tfAuthPass.focused = tfAuthPass.hit(mx0, my0);
  if (authIsRegister) tfAuthPass2.focused = tfAuthPass2.hit(mx0, my0);

  float cx = width/2, cy = height/2 - 140, mw = 380, mx = cx - mw/2;
  float fy = cy + 24 + 66 + 66 + (authIsRegister ? 66 : 0);
  if (authError.length() > 0) fy += 24;

  if (clicked(mx + 20, fy + 10, mw - 40, 42, mx0, my0)) {
    if (authIsRegister) {
      if (!tfAuthPass.value.equals(tfAuthPass2.value)) {
        authError = "Les mots de passe ne correspondent pas.";
        return;
      }
      String err = registerUser(tfAuthUser.value, tfAuthPass.value);
      if (err != null) { authError = err; return; }
      err = loginUser(tfAuthUser.value, tfAuthPass.value);
      if (err != null) { authError = err; return; }
    } else {
      String err = loginUser(tfAuthUser.value, tfAuthPass.value);
      if (err != null) { authError = err; return; }
    }
    authError = "";
    store = new DataStore(currentUser);
    store.loadAll();
    envoyerTachesVersEsp32();
    tfAuthUser.value = ""; tfAuthPass.value = ""; tfAuthPass2.value = "";
    currentScreen = authAfterLoginScreen;
    return;
  }

  if (clicked(cx - 140, fy + 62, 280, 20, mx0, my0)) {
    authIsRegister = !authIsRegister;
    authError = "";
  }
}

void loginKeyPressed() {
  tfAuthUser.handleKey();
  tfAuthPass.handleKey();
  if (authIsRegister) tfAuthPass2.handleKey();
}
