void dessinerJaugeTemperature(float cx, float cy, float rayon, float temp, boolean valide)
{
    pushStyle();
    noFill();
    stroke(80);
    strokeWeight(10);
    arc(cx, cy, rayon * 2, rayon * 2, radians(135), radians(405));

    if(valide)
    {
        float tMin = 0, tMax = 45;
        float t = constrain(temp, tMin, tMax);
        float angle = map(t, tMin, tMax, radians(135), radians(405));
        stroke(temp > 32 ? color(230, 90, 60) : color(90, 190, 230));
        arc(cx, cy, rayon * 2, rayon * 2, radians(135), angle);
    }

    noStroke();
    fill(255);
    textAlign(CENTER, CENTER);
    textSize(26);
    text(valide ? nf(temp, 0, 1) + "°C" : "--°C", cx, cy);
    textSize(12);
    fill(150);
    text("Temperature (DHT11)", cx, cy + rayon + 20);
    textAlign(LEFT, BASELINE);
    popStyle();
}

void dessinerHumidite(float x, float y, float humAir, int humSol, boolean valide)
{
    pushStyle();
    fill(255);
    textSize(14);
    text("Humidite air : " + (valide ? nf(humAir, 0, 1) + " %" : "--"), x, y);
    text("Humidite sol : " + (valide ? humSol + " %" : "--"), x, y + 25);

    noStroke();
    fill(60);
    rect(x, y + 40, 160, 14, 4);
    if(valide)
    {
        fill(90, 190, 230);
        rect(x, y + 40, map(constrain(humSol, 0, 100), 0, 100, 0, 160), 14, 4);
    }
    popStyle();
}
