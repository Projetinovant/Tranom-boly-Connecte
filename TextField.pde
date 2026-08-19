// ---- Champ de saisie texte simple (Processing n'a pas de widget natif) ----
class TField {
  float x, y, w, h;
  String label, placeholder, value = "";
  boolean focused = false;
  boolean numeric = false;

  TField(float x, float y, float w, float h, String label, String placeholder) {
    this.x = x; this.y = y; this.w = w; this.h = h;
    this.label = label; this.placeholder = placeholder;
  }

  void draw() {
    if (label != null && label.length() > 0) {
      fill(70);
      textFont(fontReg); textSize(12);
      textAlign(LEFT, BOTTOM);
      text(label, x, y - 6);
    }
    fill(255);
    stroke(focused ? cGreen() : color(220));
    strokeWeight(focused ? 2 : 1);
    rect(x, y, w, h, 8);
    noStroke();

    textFont(fontReg); textSize(13);
    textAlign(LEFT, CENTER);
    if (value.length() == 0 && !focused) {
      fill(180);
      text(placeholder, x + 10, y + h/2);
    } else {
      fill(30);
      text(value, x + 10, y + h/2);
      if (focused && (millis()/500) % 2 == 0) {
        float tw = textWidth(value);
        stroke(30);
        line(x + 10 + tw, y + 8, x + 10 + tw, y + h - 8);
        noStroke();
      }
    }
  }

  boolean hit(float mx, float my) {
    return mx > x && mx < x + w && my > y && my < y + h;
  }

  void handleKey() {
    if (!focused) return;
    if (key == BACKSPACE) {
      if (value.length() > 0) value = value.substring(0, value.length() - 1);
    } else if (key == CODED) {
      // ignore flèches, etc.
    } else if (key == '\n' || key == '\r' || key == TAB) {
      // ignore
    } else {
      if (numeric && !(Character.isDigit(key) || key == '.')) return;
      value += key;
    }
  }
}
