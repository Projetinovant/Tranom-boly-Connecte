// ---- Notifications (cloche dans la barre de navigation) ----
boolean notifPanelOpen = false;
float notifBellX, notifBellY = 20, notifBellSize = 24;

void drawNotifBell() {
  notifBellX = width - 100;
  int unread = (store != null) ? store.unreadCount() : 0;

  fill(90);
  noStroke();
  ellipse(notifBellX, navH/2, notifBellSize, notifBellSize);
  fill(255); textFont(fontBold); textSize(12); textAlign(CENTER, CENTER);
  text("N", notifBellX, navH/2);

  if (unread > 0) {
    fill(cRed());
    ellipse(notifBellX + 10, navH/2 - 10, 14, 14);
    fill(255); textFont(fontReg); textSize(8);
    text("" + min(unread,9), notifBellX + 10, navH/2 - 10);
  }

  if (notifPanelOpen) drawNotifPanel();
}

void drawNotifPanel() {
  float pw = 320, ph = 360;
  float px = notifBellX - pw + 20, py = navH + 4;
  fill(255); stroke(cBorder()); strokeWeight(1);
  rect(px, py, pw, ph, 12);
  noStroke();

  fill(cText()); textFont(fontBold); textSize(13); textAlign(LEFT, TOP);
  text("Notifications", px + 16, py + 12);

  ArrayList<Notif> list = (store != null) ? store.notifs : new ArrayList<Notif>();
  if (list.isEmpty()) {
    fill(170); textAlign(CENTER, CENTER); textFont(fontReg); textSize(11);
    text("Aucune notification.", px + pw/2, py + ph/2);
    return;
  }

  float ry = py + 40;
  for (int i = 0; i < list.size() && i < 8; i++) {
    Notif n = list.get(i);
    fill(n.read ? color(210) : cGreen());
    noStroke(); ellipse(px + 14, ry + 8, 8, 8);
    fill(n.read ? color(140) : cText());
    textFont(fontReg); textSize(10); textAlign(LEFT, TOP);
    text(n.message, px + 28, ry, pw - 44, 30);
    fill(170); textSize(8);
    text(n.time, px + 28, ry + 26);
    ry += 42;
  }
}

boolean notifMousePressed(float mx, float my) {
  if (clicked(notifBellX - 14, navH/2 - 14, 28, 28, mx, my)) {
    notifPanelOpen = !notifPanelOpen;
    if (notifPanelOpen && store != null) store.markAllRead();
    return true;
  }
  if (notifPanelOpen) {
    float pw = 320, ph = 360;
    float px = notifBellX - pw + 20, py = navH + 4;
    if (!clicked(px, py, pw, ph, mx, my)) {
      notifPanelOpen = false;
      return true; // consomme le clic pour fermer sans déclencher autre chose
    }
  }
  return false;
}
