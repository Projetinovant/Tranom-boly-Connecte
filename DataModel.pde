class Task {
  String title, priority;
  boolean done;
  Task(String t, String p, boolean d) { title = t; priority = p; done = d; }
}

class Depense {
  String libelle, date;
  double montant;
  Depense(String l, double m, String d) { libelle = l; montant = m; date = d; }
}

class Recolte {
  String culture, parcelle, date;
  double qteKg, valeurAr;
  Recolte(String c, String p, double q, double v, String d) { culture = c; parcelle = p; qteKg = q; valeurAr = v; date = d; }
}

class VenteItem {
  String culture, acheteur, date;
  float qteKg, prixKg, montantTotal;
  VenteItem(String c, float q, float p, float t, String a, String d) {
    culture = c; qteKg = q; prixKg = p; montantTotal = t; acheteur = a; date = d;
  }
}

class ContactMsg {
  String nom, email, sujet, message;
  ContactMsg(String n, String e, String s, String m) { nom = n; email = e; sujet = s; message = m; }
}

class Notif {
  String message, time;
  boolean read;
  Notif(String m, String t, boolean r) { message = m; time = t; read = r; }
}

class SensorSample {
  long t;
  float temp, humAir, humSol, lux;
  SensorSample(long t, float a, float b, float c, float d) { this.t=t; temp=a; humAir=b; humSol=c; lux=d; }
}

class DataStore {
  String username;
  String dir;

  ArrayList<Task> tasks = new ArrayList<Task>();
  ArrayList<Depense> depenses = new ArrayList<Depense>();
  ArrayList<Recolte> recoltes = new ArrayList<Recolte>();
  ArrayList<VenteItem> ventes = new ArrayList<VenteItem>();
  ArrayList<ContactMsg> contacts = new ArrayList<ContactMsg>();
  ArrayList<Notif> notifs = new ArrayList<Notif>();
  ArrayList<SensorSample> sensorHistory = new ArrayList<SensorSample>();

  DataStore(String username) {
    this.username = username;
    this.dir = "users/" + username + "/";
  }

  void loadAll() {
    loadTasks(); loadDepenses(); loadRecoltes(); loadVentes(); loadNotifs(); loadSensorHistory();
  }

  String nowTime() {
    return nf(hour(),2) + ":" + nf(minute(),2) + " " + today();
  }

  void addNotif(String msg) {
    notifs.add(0, new Notif(msg, nowTime(), false));
    while (notifs.size() > 80) notifs.remove(notifs.size()-1);
    saveNotifs();
  }

  int unreadCount() {
    int n = 0;
    for (Notif nn : notifs) if (!nn.read) n++;
    return n;
  }

  void markAllRead() {
    for (Notif nn : notifs) nn.read = true;
    saveNotifs();
  }

  // ---- Taches ----
  void loadTasks() {
    tasks.clear();
    String[] lines = loadStrings(dir + "tasks.csv");
    if (lines == null) return;
    for (String l : lines) {
      if (l.trim().length() == 0) continue;
      String[] p = l.split("\\|", -1);
      if (p.length >= 3) tasks.add(new Task(p[0], p[1], p[2].equals("1")));
    }
  }
  void saveTasks() {
    String[] out = new String[tasks.size()];
    for (int i = 0; i < tasks.size(); i++) {
      Task t = tasks.get(i);
      out[i] = t.title + "|" + t.priority + "|" + (t.done ? "1" : "0");
    }
    saveStrings("data/" + dir + "tasks.csv", out);
  }
  void deleteTask(int idx) { tasks.remove(idx); saveTasks(); }

  // ---- Depenses ----
  void loadDepenses() {
    depenses.clear();
    String[] lines = loadStrings(dir + "depenses.csv");
    if (lines == null) return;
    for (String l : lines) {
      if (l.trim().length() == 0) continue;
      String[] p = l.split("\\|", -1);
      if (p.length >= 3) {
        try { depenses.add(new Depense(p[0], Double.parseDouble(p[1]), p[2])); } catch (Exception e) {}
      }
    }
  }
  void saveDepenses() {
    String[] out = new String[depenses.size()];
    for (int i = 0; i < depenses.size(); i++) {
      Depense d = depenses.get(i);
      out[i] = d.libelle + "|" + d.montant + "|" + d.date;
    }
    saveStrings("data/" + dir + "depenses.csv", out);
  }
  void deleteDepense(int idx) { depenses.remove(idx); saveDepenses(); }

  // ---- Recoltes ----
  void loadRecoltes() {
    recoltes.clear();
    String[] lines = loadStrings(dir + "recoltes.csv");
    if (lines == null) {
      recoltes.add(new Recolte("Tomates", "Parcelle A", 3000, 700000, today()));
      recoltes.add(new Recolte("Riz", "Parcelle B", 2000, 300000, today()));
      saveRecoltes();
      return;
    }
    for (String l : lines) {
      if (l.trim().length() == 0) continue;
      String[] p = l.split("\\|", -1);
      if (p.length >= 5) {
        try { recoltes.add(new Recolte(p[0], p[1], Double.parseDouble(p[2]), Double.parseDouble(p[3]), p[4])); } catch (Exception e) {}
      }
    }
  }
  void saveRecoltes() {
    String[] out = new String[recoltes.size()];
    for (int i = 0; i < recoltes.size(); i++) {
      Recolte r = recoltes.get(i);
      out[i] = r.culture + "|" + r.parcelle + "|" + r.qteKg + "|" + r.valeurAr + "|" + r.date;
    }
    saveStrings("data/" + dir + "recoltes.csv", out);
  }
  void deleteRecolte(int idx) { recoltes.remove(idx); saveRecoltes(); }

  // ---- Ventes ----
  void loadVentes() {
    ventes.clear();
    String[] lines = loadStrings(dir + "ventes.csv");
    if (lines == null) return;
    for (String l : lines) {
      if (l.trim().length() == 0) continue;
      String[] p = l.split("\\|", -1);
      if (p.length >= 6) {
        try {
          ventes.add(new VenteItem(p[0], Float.parseFloat(p[1]), Float.parseFloat(p[2]),
                                    Float.parseFloat(p[3]), p[4], p[5]));
        } catch (Exception e) {}
      }
    }
  }
  void saveVentes() {
    String[] out = new String[ventes.size()];
    for (int i = 0; i < ventes.size(); i++) {
      VenteItem v = ventes.get(i);
      out[i] = v.culture + "|" + v.qteKg + "|" + v.prixKg + "|" + v.montantTotal + "|" + v.acheteur + "|" + v.date;
    }
    saveStrings("data/" + dir + "ventes.csv", out);
  }
  void deleteVente(int idx) { ventes.remove(idx); saveVentes(); }

  // ---- Notifications ----
  void loadNotifs() {
    notifs.clear();
    String[] lines = loadStrings(dir + "notifications.csv");
    if (lines == null) return;
    for (String l : lines) {
      if (l.trim().length() == 0) continue;
      String[] p = l.split("\\|", -1);
      if (p.length >= 3) notifs.add(new Notif(p[0], p[1], p[2].equals("1")));
    }
  }
  void saveNotifs() {
    String[] out = new String[notifs.size()];
    for (int i = 0; i < notifs.size(); i++) {
      Notif nn = notifs.get(i);
      out[i] = nn.message + "|" + nn.time + "|" + (nn.read ? "1" : "0");
    }
    saveStrings("data/" + dir + "notifications.csv", out);
  }

  // ---- Historique capteurs (reel, construit au fil de l'execution) ----
  void loadSensorHistory() {
    sensorHistory.clear();
    String[] lines = loadStrings(dir + "sensor_history.csv");
    if (lines == null) return;
    for (String l : lines) {
      if (l.trim().length() == 0) continue;
      String[] p = l.split("\\|", -1);
      if (p.length >= 5) {
        try {
          sensorHistory.add(new SensorSample(Long.parseLong(p[0]), Float.parseFloat(p[1]),
                             Float.parseFloat(p[2]), Float.parseFloat(p[3]), Float.parseFloat(p[4])));
        } catch (Exception e) {}
      }
    }
  }
  void addSensorSample(float temp, float humAir, float humSol, float lux) {
    sensorHistory.add(new SensorSample(System.currentTimeMillis(), temp, humAir, humSol, lux));
    while (sensorHistory.size() > 200) sensorHistory.remove(0);
    saveSensorHistory();
  }
  void saveSensorHistory() {
    String[] out = new String[sensorHistory.size()];
    for (int i = 0; i < sensorHistory.size(); i++) {
      SensorSample s = sensorHistory.get(i);
      out[i] = s.t + "|" + s.temp + "|" + s.humAir + "|" + s.humSol + "|" + s.lux;
    }
    saveStrings("data/" + dir + "sensor_history.csv", out);
  }
}
