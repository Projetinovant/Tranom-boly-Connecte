float userLat = -18.91, userLon = 47.52; // valeur par défaut : Antananarivo, tant que la géoloc n'a pas répondu
boolean geoLoading = true;
boolean geoReal = false;

void fetchGeoAsync() {
  geoLoading = true;
  thread("doFetchGeo");
}

void doFetchGeo() {
  try {
    JSONObject json = loadJSONObject("http://ip-api.com/json/");
    if (json != null && json.getString("status","").equals("success")) {
      userLat = (float) json.getDouble("lat");
      userLon = (float) json.getDouble("lon");
      geoReal = true;
    }
  } catch (Exception e) {
    println("Géolocalisation indisponible : " + e.getMessage());
  } finally {
    geoLoading = false;
  }
}

// Distance réelle en km entre deux points GPS (formule de haversine)
float haversineKm(float lat1, float lon1, float lat2, float lon2) {
  float R = 6371;
  float dLat = radians(lat2 - lat1);
  float dLon = radians(lon2 - lon1);
  float a = sin(dLat/2) * sin(dLat/2) +
            cos(radians(lat1)) * cos(radians(lat2)) * sin(dLon/2) * sin(dLon/2);
  float c = 2 * atan2(sqrt(a), sqrt(1-a));
  return R * c;
}
