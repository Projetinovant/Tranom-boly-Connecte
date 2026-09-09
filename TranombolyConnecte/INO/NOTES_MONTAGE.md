# Tranom-boly Connecté — Notes de montage (ESP32)

## Bibliothèques Arduino à installer (Gestionnaire de bibliothèques)
- **ESP32Servo** — pilotage des 4 servos
- **DHT sensor library** (Adafruit) + **Adafruit Unified Sensor** (dépendance)
- **arduinoFFT** — analyse spectrale

⚠️ **Servo** : installer la bibliothèque nommée exactement **"ESP32Servo"** (auteur
Kevin Harrington / John K. Bennett — c'est la bibliothèque standard et la plus utilisée).
Si le Gestionnaire de bibliothèques propose une variante comme "ESP32Servo360", ne pas
l'utiliser : son API (`write()`) est pensée pour des servos à rotation continue et ne
correspond pas au contrôle d'angle utilisé dans `porte.cpp`.

⚠️ Le watchdog matériel (`esp_task_wdt`) a été retiré : son header n'est pas disponible
dans toutes les configurations de cœur ESP32 (dépend de la version installée). Ce n'était
qu'un renfort de robustesse optionnel, pas une fonction essentielle du projet.

✅ Confirmé sur ce projet : cœur **Arduino-ESP32 v3.3.11**, carte **ESP32 Dev Module**.
`microphone.cpp` est écrit pour l'API timer de cette version (`timerBegin(frequence)` +
`timerAlarm(...)`). Si tu changes un jour de machine/cœur vers une version 2.x plus
ancienne, il faudra revenir à l'ancienne API — voir le commentaire en tête du fichier.

⚠️ Reste un point non encore vérifié : l'API de **arduinoFFT** (frequence.cpp). Si la
compilation échoue à ce fichier, copie-moi le message d'erreur exact.

## Table de brochage (voir aussi config.h)

| Broche ESP32 | Fonction |
|---|---|
| 34 | Micro extérieur KY-037 (analyse fréquentielle) |
| 35 | Micro intérieur KY-037 (référence bruit ambiant) |
| 32 | Photorésistance |
| 33 | Capteur humidité sol (capacitif) |
| 27 | DHT11 |
| 13 | Servo porte anti-nuisible |
| 14 | Servo porte eau (réservoir) |
| 25 | Servo porte engrais (réservoir) |
| 26 | Servo porte distribution (réservoir) |
| 22 | Capteur de niveau réservoir (2 fils dénudés) |
| 16 | Buzzer répulsion |
| 17 | LED rouge (état ALERTE) |
| 18 | LED verte (porte anti-nuisible ouverte) |
| 19 / 23 / 21 | LED RGB répulsion (R/G/B) |
| 4 | Moteur vibrant (pollinisation) |

## Calibrations à faire sur site (valeurs actuelles = points de départ, pas des mesures)
- **sol.cpp** : `ADC_SOL_SEC` / `ADC_SOL_HUMIDE` — lire la sonde à l'air puis dans l'eau.
- **classification.cpp** : les 3 bandes de fréquence (papillon/pollinisateur/nuisible-vol)
  viennent de la littérature acoustique entomologique générale, pas d'une mesure sur vos
  insectes réels. Utiliser les boutons du tableau de bord + les trames `S;` (spectre) pour
  observer les vraies fréquences dominantes de vos spécimens et ajuster `frequence.h`.
- **reservoir.cpp** : `DELAI_MAX_REMPLISSAGE_MS` / `DELAI_DISTRIBUTION_MS` à ajuster selon
  le débit réel de vos bouteilles et la taille du réservoir.
- **pollinisation.cpp** : `SEUIL_LUMINOSITE_JOUR` dépend de votre photorésistance précise.

## Choix assumés (limites documentées, pas des oublis)
- **Engrais** : jamais déclenché automatiquement (pas de capteur EC/pH). Se déclenche
  uniquement via le bouton "Arroser (engrais)" du tableau de bord.
- **Dosage eau/engrais** : géré par la géométrie des bouteilles inversées + une durée
  calibrée, pas par une mesure chimique — cohérent avec le dossier technique.
- **LCD abandonné** : toute l'information visuelle en temps réel vit dans le tableau de
  bord Processing ; seule la LED verte reste en local (porte ouverte).

## Menu de robustesse : ce qui est implémenté
Acquisition suspendue pendant la répulsion/pollinisation • détection de saturation ADC •
bruit de fond adaptatif (auto-recalibrage) • FFT + Goertzel ciblé + harmonique •
régularité temporelle • compensation température • vote sur historique (anti-oscillation) •
double micro (validation croisée) • budget horaire + motif aléatoire pour la répulsion •
autotest DHT11 au démarrage.

**Volontairement écarté** (à ta demande) : capteur de pluie (absent du kit).
