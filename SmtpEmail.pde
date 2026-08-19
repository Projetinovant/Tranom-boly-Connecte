boolean smtpConfigured() {
  String[] cfg = loadStrings("smtp_config.txt");
  return cfg != null && cfg.length >= 4;
}

// Retourne null si succès, sinon un message d'erreur
String sendEmailReal(String toDefault, String fromName, String fromEmailReply, String subject, String body) {
  String[] cfg = loadStrings("smtp_config.txt");
  if (cfg == null || cfg.length < 4) return "SMTP non configuré (voir data/smtp_config.txt)";

  String host = cfg[0].trim();
  int port = Integer.parseInt(cfg[1].trim());
  String user = cfg[2].trim();
  String pass = cfg[3].trim();
  String dest = toDefault;

  javax.net.ssl.SSLSocket socket = null;
  try {
    javax.net.ssl.SSLSocketFactory factory = (javax.net.ssl.SSLSocketFactory) javax.net.ssl.SSLSocketFactory.getDefault();
    socket = (javax.net.ssl.SSLSocket) factory.createSocket(host, port);
    java.io.BufferedReader in = new java.io.BufferedReader(new java.io.InputStreamReader(socket.getInputStream()));
    java.io.PrintWriter out = new java.io.PrintWriter(socket.getOutputStream(), true);

    readSmtp(in);
    out.print("EHLO localhost\r\n"); out.flush(); readSmtp(in);
    out.print("AUTH LOGIN\r\n"); out.flush(); readSmtp(in);
    out.print(base64(user) + "\r\n"); out.flush(); readSmtp(in);
    out.print(base64(pass) + "\r\n"); out.flush();
    String authResp = readSmtp(in);
    if (!authResp.startsWith("235")) return "Authentification SMTP refusée.";

    out.print("MAIL FROM:<" + user + ">\r\n"); out.flush(); readSmtp(in);
    out.print("RCPT TO:<" + dest + ">\r\n"); out.flush(); readSmtp(in);
    out.print("DATA\r\n"); out.flush(); readSmtp(in);

    String msg = "From: " + fromName + " <" + user + ">\r\n" +
                 "Reply-To: " + fromEmailReply + "\r\n" +
                 "To: " + dest + "\r\n" +
                 "Subject: [Tranom-boliko] " + subject + "\r\n" +
                 "Content-Type: text/plain; charset=UTF-8\r\n\r\n" +
                 body + "\r\n.\r\n";
    out.print(msg); out.flush();
    String dataResp = readSmtp(in);
    if (!dataResp.startsWith("250")) return "Le serveur SMTP a refusé le message.";

    out.print("QUIT\r\n"); out.flush();
    socket.close();
    return null; // succès
  } catch (Exception e) {
    return "Erreur SMTP : " + e.getMessage();
  } finally {
    try { if (socket != null && !socket.isClosed()) socket.close(); } catch (Exception e) {}
  }
}

String readSmtp(java.io.BufferedReader in) throws java.io.IOException {
  String line, last = "";
  while ((line = in.readLine()) != null) {
    last = line;
    if (line.length() < 4 || line.charAt(3) != '-') break; // fin de la réponse multi-ligne
  }
  return last;
}

String base64(String s) {
  return java.util.Base64.getEncoder().encodeToString(s.getBytes());
}
