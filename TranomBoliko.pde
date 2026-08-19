PFont fontReg, fontBold, fontBig;

String currentScreen = "accueil";

DataStore store;
Sensors sensors;

WeatherData weather;
boolean weatherLoading = true;
String weatherError = null;
long lastWeatherFetchTime = -999999;
final long WEATHER_REFRESH_MS = 15 * 60 * 1000;

void settings() {
  size(1300, 900);
}

void setup() {
  surface.setTitle("Tranom-boliko -- JGTech");
  surface.setResizable(true);
  fontReg  = createFont("Arial", 14, true);
  fontBold = createFont("Arial Bold", 14, true);
  fontBig  = createFont("Arial Bold", 26, true);
  textFont(fontReg);

  store = new DataStore("guest"); // session anonyme locale tant que personne n'est connecte
  store.loadAll();

  sensors = new Sensors();

  initEspacesFields();
  initVentesUserFields();
  initRecoltesFields();
  initContactFields();
  initVenteData();
  initAuthFields();

  lastWeatherFetchTime = millis();
  fetchWeatherAsync();
  fetchGeoAsync();
  initSerial();
  envoyerTachesVersEsp32();
}

long lastTaskResyncTime = 0;
final long TASK_RESYNC_MS = 60000;

void draw() {
  background(245, 246, 247);
  sensors.update();

  if (millis() - lastWeatherFetchTime > WEATHER_REFRESH_MS && !weatherLoading) {
    lastWeatherFetchTime = millis();
    fetchWeatherAsync();
  }

  if (millis() - lastTaskResyncTime > TASK_RESYNC_MS) {
    lastTaskResyncTime = millis();
    envoyerTachesVersEsp32();
  }

  switch(currentScreen) {
    case "accueil":    drawAccueil();    break;
    case "dashboard":  drawDashboard();  break;
    case "espaces":    drawEspaces();    break;
    case "vente":      drawVente();      break;
    case "ventesUser": drawVentesUser(); break;
    case "recoltes":   drawRecoltes();   break;
    case "meteo":      drawMeteo();      break;
    case "contact":    drawContact();    break;
    case "help":       drawHelp();       break;
    case "login":      drawLogin();      break;
  }

  if (!currentScreen.equals("login")) drawNavbar();
}

void mousePressed() {
  if (!currentScreen.equals("login") && handleNavbarClick(mouseX, mouseY)) return;

  switch(currentScreen) {
    case "dashboard":  dashboardMousePressed(mouseX, mouseY);  break;
    case "espaces":    espacesMousePressed(mouseX, mouseY);    break;
    case "vente":      venteMousePressed(mouseX, mouseY);      break;
    case "ventesUser": ventesUserMousePressed(mouseX, mouseY); break;
    case "recoltes":   recoltesMousePressed(mouseX, mouseY);   break;
    case "contact":    contactMousePressed(mouseX, mouseY);    break;
    case "accueil":    accueilMousePressed(mouseX, mouseY);    break;
    case "login":      loginMousePressed(mouseX, mouseY);      break;
  }
}

void keyPressed() {
  switch(currentScreen) {
    case "espaces":    espacesKeyPressed();    break;
    case "vente":      venteKeyPressed();      break;
    case "ventesUser": ventesUserKeyPressed(); break;
    case "recoltes":   recoltesKeyPressed();   break;
    case "contact":    contactKeyPressed();    break;
    case "login":      loginKeyPressed();      break;
  }
}

String today() {
  return year() + "-" + nf(month(),2) + "-" + nf(day(),2);
}

String moisFr(int m) {
  String[] mois = {"","Janvier","Fevrier","Mars","Avril","Mai","Juin","Juillet","Aout","Septembre","Octobre","Novembre","Decembre"};
  return mois[m];
}
