class DayForecast {
  String date;
  float tmax, tmin;
  int rainPct;
  int code;
}

class WeatherData {
  float temperature, humidity, wind, pressure, rain, visibility;
  int uv;
  int weatherCode;
  DayForecast[] forecast;
}

void fetchWeatherAsync() {
  weatherLoading = true;
  weatherError = null;
  thread("doFetchWeather");
}

void doFetchWeather() {
  try {
    String url = "https://api.open-meteo.com/v1/forecast?latitude=-18.91&longitude=47.52"
      + "&current=temperature_2m,relative_humidity_2m,precipitation,weather_code,wind_speed_10m,surface_pressure,uv_index"
      + "&daily=weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max"
      + "&timezone=Africa%2FNairobi";

    JSONObject json = loadJSONObject(url);
    if (json == null) throw new Exception("Réponse vide de l'API météo");

    WeatherData w = new WeatherData();
    JSONObject cur = json.getJSONObject("current");
    w.temperature = (float) cur.getDouble("temperature_2m");
    w.humidity    = (float) cur.getDouble("relative_humidity_2m");
    w.wind        = (float) cur.getDouble("wind_speed_10m");
    w.pressure    = (float) cur.getDouble("surface_pressure");
    w.rain        = cur.hasKey("precipitation") ? (float) cur.getDouble("precipitation") : 0;
    w.uv          = cur.hasKey("uv_index") ? round((float) cur.getDouble("uv_index")) : 0;
    w.weatherCode = cur.getInt("weather_code");
    w.visibility  = 10; // non fourni par l'API horaire gratuite ; valeur indicative

    JSONObject daily = json.getJSONObject("daily");
    JSONArray dates  = daily.getJSONArray("time");
    JSONArray codes  = daily.getJSONArray("weather_code");
    JSONArray tmax   = daily.getJSONArray("temperature_2m_max");
    JSONArray tmin   = daily.getJSONArray("temperature_2m_min");
    JSONArray rainp  = daily.getJSONArray("precipitation_probability_max");

    int n = min(7, dates.size());
    w.forecast = new DayForecast[n];
    for (int i = 0; i < n; i++) {
      DayForecast d = new DayForecast();
      d.date    = dates.getString(i);
      d.code    = codes.getInt(i);
      d.tmax    = (float) tmax.getDouble(i);
      d.tmin    = (float) tmin.getDouble(i);
      d.rainPct = rainp.getInt(i);
      w.forecast[i] = d;
    }

    weather = w;
    weatherLoading = false;
    weatherError = null;
  } catch (Exception e) {
    println("Erreur météo : " + e.getMessage());
    weatherError = "Erreur de connexion météo.";
    weatherLoading = false;
  }
}

// Table des codes météo WMO -> libellé en français
String weatherLabel(int code) {
  if (code == 0) return "Ensoleillé";
  if (code == 1 || code == 2) return "Partiellement nuageux";
  if (code == 3) return "Nuageux";
  if (code == 45 || code == 48) return "Brumeux";
  if (code >= 51 && code <= 57) return "Bruine";
  if (code >= 61 && code <= 67) return "Pluie";
  if (code >= 71 && code <= 77) return "Neige";
  if (code >= 80 && code <= 82) return "Averses";
  if (code >= 95) return "Orage";
  return "Variable";
}

String frDayName(String isoDate) {
  String[] days = {"Dim","Lun","Mar","Mer","Jeu","Ven","Sam"};
  try {
    java.time.LocalDate d = java.time.LocalDate.parse(isoDate);
    int dow = d.getDayOfWeek().getValue() % 7; // Lundi=1..Dimanche=7 -> Dimanche=0
    return days[dow];
  } catch (Exception e) {
    return "?";
  }
}
