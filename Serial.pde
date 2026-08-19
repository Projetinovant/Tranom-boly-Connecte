import processing.serial.*;

Serial esp32Port = null;
boolean hardwareConnected = false;

void initSerial() {
  try {
    String[] ports = Serial.list();
    if (ports == null || ports.length == 0) { hardwareConnected = false; return; }
    String configured = null;
    String[] cfg = loadStrings("serial_config.txt");
    if (cfg != null && cfg.length > 0 && cfg[0].trim().length() > 0) configured = cfg[0].trim();
    String chosen = (configured != null) ? configured : ports[0];
    esp32Port = new Serial(this, chosen, 115200);
    esp32Port.bufferUntil('\n');
    hardwareConnected = true;
    println("Port serie ouvert : " + chosen);
  } catch (Exception e) {
    hardwareConnected = false;
    println("Aucun ESP32 detecte (mode simulation environnement) : " + e.getMessage());
  }
}

void envoyerCommandeSerial(String commande) {
  if (hardwareConnected && esp32Port != null) {
    try { esp32Port.write(commande + "\n"); } catch (Exception e) {}
  }
}

void arroserEau()        { envoyerCommandeSerial("ARROSER_EAU"); }
void ouvrirPorteManuel() { envoyerCommandeSerial("PORTE_OUVRIR"); }
void fermerPorteManuel() { envoyerCommandeSerial("PORTE_FERMER"); }
void testerRepulsion()   { envoyerCommandeSerial("TEST_REPULSION"); }

// Envoie la liste des taches en attente (non terminees) pour affichage LCD.
void envoyerTachesVersEsp32() {
  if (store == null) return;
  StringBuilder sb = new StringBuilder();
  int n = 0;
  for (Task t : store.tasks) {
    if (t.done) continue;
    if (n > 0) sb.append("|");
    // le protocole utilise ';' et '|' comme separateurs : on les retire des titres
    sb.append(t.title.replace(";","").replace("|",""));
    n++;
    if (n >= 8) break; // limite cote ecran LCD (voir ecran.cpp)
  }
  envoyerCommandeSerial("TACHES;" + n + ";" + sb.toString());
}

void serialEvent(Serial p) {
  try {
    String line = p.readStringUntil('\n');
    if (line == null) return;
    line = line.trim();
    if (line.length() == 0) return;

    String[] champs = line.split(";");
    if (champs.length == 0) return;
    String tag = champs[0];

    if (tag.equals("E") && champs.length >= 6) {
      sensors.etatSysteme = int(champs[1]);
      sensors.typeInsecte = int(champs[2]);
      sensors.confiance = float(champs[3]);
      sensors.repulsion = champs[4].equals("1");
      sensors.porteOuverte = champs[5].equals("1");
      sensors.fromHardware = true;
      sensors.lastHardwareMsg = millis();
    } else if (tag.equals("M") && champs.length >= 5) {
      sensors.temperature = float(champs[1]);
      sensors.humidityAir = float(champs[2]);
      sensors.luminosity = float(champs[3]);
      sensors.humiditySoil = float(champs[4]);
      sensors.fromHardware = true;
      sensors.lastHardwareMsg = millis();
      if (store != null) store.addSensorSample(sensors.temperature, sensors.humidityAir, sensors.humiditySoil, sensors.luminosity);
    } else if (tag.equals("R") && champs.length >= 2) {
      sensors.irrigationActive = champs[1].equals("1");
      sensors.fromHardware = true;
      sensors.lastHardwareMsg = millis();
    } else if (tag.equals("S") && champs.length >= 3) {
      sensors.freqDominante = float(champs[1]);
      sensors.ampDominante = float(champs[2]);
      if (champs.length >= 4) {
        String[] valeurs = champs[3].split(",");
        int n = min(valeurs.length, sensors.spectre.length);
        for (int i = 0; i < n; i++) {
          try { sensors.spectre[i] = float(valeurs[i]); } catch (Exception e) { sensors.spectre[i] = 0; }
        }
      }
      sensors.fromHardware = true;
      sensors.lastHardwareMsg = millis();
    }
    // "A;DHT11=OK/ECHEC" (autotest de demarrage) : ignore, informatif uniquement au demarrage
  } catch (Exception e) {
    // ligne malformee : on l'ignore simplement
  }
}
