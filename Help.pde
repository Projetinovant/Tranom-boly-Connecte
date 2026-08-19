// ---- Aide ----
String[][] helpItems = {
  {"Comment ajouter une tâche ?", "Allez dans \"Espaces utilisateurs\" puis cliquez sur \"+ Nouvelle\" dans la carte Tâches à faire."},
  {"Comment enregistrer une vente ?", "Allez dans \"Vente & Marchés\" puis \"Mes ventes\" > \"+ Nouvelle vente\"."},
  {"D'où viennent les données météo ?", "De l'API publique Open-Meteo, en temps réel, pour Antananarivo."},
  {"Les capteurs sont-ils réels ?", "Simulés par défaut. Si vous branchez un ESP32/Arduino compatible (voir data/serial_config.txt), les vraies valeurs s'affichent automatiquement."},
  {"Où sont stockées mes données ?", "Localement, dans le dossier data/users/<votre nom> de ce sketch. Rien n'est envoyé sur Internet, sauf la météo et la géolocalisation IP."},
  {"Comment synchroniser mes données entre deux ordinateurs ?", "Déplacez tout le dossier data/ dans un dossier Dropbox/Google Drive partagé : comme ce sont de simples fichiers, ils se synchroniseront automatiquement."},
  {"Comment fonctionne \"Autour de moi\" ?", "Votre position approximative est déduite de votre adresse IP publique, puis une vraie distance (formule de haversine) est calculée vers chaque marché."},
  {"L'envoi d'email du formulaire de contact fonctionne-t-il ?", "Le message est toujours enregistré localement. Pour un envoi email réel, renseignez data/smtp_config.txt avec vos propres identifiants SMTP."}
};

void drawHelp() {
  float top = navH + 24;
  fill(cGreen());
  textFont(fontBig); textSize(22); textAlign(LEFT, TOP);
  text("Aide", 40, top);
  fill(140);
  textFont(fontReg); textSize(12);
  text("Questions fréquentes sur le fonctionnement de l'application.", 40, top + 28);

  float y = top + 60;
  for (String[] item : helpItems) {
    float h = 70;
    card(40, y, width - 80, h);
    fill(cText()); textFont(fontBold); textSize(13); textAlign(LEFT, TOP);
    text(item[0], 60, y + 12);
    fill(110); textFont(fontReg); textSize(11);
    text(item[1], 60, y + 34, width - 160, 32);
    y += h + 12;
  }
}
