class UserAccount {
  String username, passHash, salt;
  UserAccount(String u, String h, String s) { username = u; passHash = h; salt = s; }
}

String currentUser = null; // null = non connecté

String sha256Hex(String s) {
  try {
    java.security.MessageDigest md = java.security.MessageDigest.getInstance("SHA-256");
    byte[] digest = md.digest(s.getBytes("UTF-8"));
    StringBuilder sb = new StringBuilder();
    for (byte b : digest) sb.append(String.format("%02x", b));
    return sb.toString();
  } catch (Exception e) { return null; }
}

String randomSalt() {
  byte[] b = new byte[8];
  new java.security.SecureRandom().nextBytes(b);
  StringBuilder sb = new StringBuilder();
  for (byte x : b) sb.append(String.format("%02x", x));
  return sb.toString();
}

ArrayList<UserAccount> loadUsers() {
  ArrayList<UserAccount> list = new ArrayList<UserAccount>();
  String[] lines = loadStrings("users.csv");
  if (lines == null) return list;
  for (String l : lines) {
    if (l.trim().length() == 0) continue;
    String[] p = l.split("\\|", -1);
    if (p.length >= 3) list.add(new UserAccount(p[0], p[1], p[2]));
  }
  return list;
}

void saveUsers(ArrayList<UserAccount> list) {
  String[] out = new String[list.size()];
  for (int i = 0; i < list.size(); i++) {
    UserAccount u = list.get(i);
    out[i] = u.username + "|" + u.passHash + "|" + u.salt;
  }
  saveStrings("data/users.csv", out);
}

UserAccount findUser(String username) {
  for (UserAccount u : loadUsers()) if (u.username.equalsIgnoreCase(username)) return u;
  return null;
}

// Retourne un message d'erreur, ou null si l'inscription a réussi
String registerUser(String username, String password) {
  username = username.trim();
  if (username.length() < 3) return "Le nom d'utilisateur doit faire au moins 3 caractères.";
  if (password.length() < 4) return "Le mot de passe doit faire au moins 4 caractères.";
  if (findUser(username) != null) return "Ce nom d'utilisateur existe déjà.";
  ArrayList<UserAccount> list = loadUsers();
  String salt = randomSalt();
  String hash = sha256Hex(salt + password);
  list.add(new UserAccount(username, hash, salt));
  saveUsers(list);
  return null;
}

// Retourne un message d'erreur, ou null si la connexion a réussi
String loginUser(String username, String password) {
  UserAccount u = findUser(username.trim());
  if (u == null) return "Utilisateur inconnu.";
  String hash = sha256Hex(u.salt + password);
  if (!hash.equals(u.passHash)) return "Mot de passe incorrect.";
  currentUser = u.username;
  return null;
}

void logoutUser() {
  currentUser = null;
  currentScreen = "accueil";
}

// Redirige vers l'écran login si la page demandée nécessite une connexion
void gotoScreen(String s) {
  boolean needsLogin = s.equals("espaces") || s.equals("ventesUser") || s.equals("recoltes");
  if (needsLogin && currentUser == null) {
    authAfterLoginScreen = s;
    currentScreen = "login";
    return;
  }
  currentScreen = s;
}
