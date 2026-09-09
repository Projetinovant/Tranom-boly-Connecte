#ifndef CONFIG_H
#define CONFIG_H

// =====================================================================
//  BROCHAGE CENTRAL - ESP32 DevKit (30/38 broches)
//  Un seul endroit a modifier si le cablage change : tous les modules
//  incluent ce fichier plutot que de coder un numero de broche en dur.
// =====================================================================

// --- Microphones KY-037 (ADC1 -> compatible avec un usage WiFi futur) ---
#define PIN_MIC_EXTERIEUR      34   // entree seule, tourne vers la culture
#define PIN_MIC_INTERIEUR      35   // entree seule, reference de bruit ambiant

// --- Capteurs analogiques environnement ---
#define PIN_PHOTORESISTANCE    32
#define PIN_HUMIDITE_SOL       33

// --- Capteur numerique air (DHT11, 1 fil) ---
#define PIN_DHT11               27

// --- Servo de la porte anti-nuisible (existant) ---
#define PIN_SERVO_PORTE_INSECTE 13

// --- Servos du reservoir eau / engrais ---
#define PIN_SERVO_PORTE_EAU          14
#define PIN_SERVO_PORTE_ENGRAIS      25
#define PIN_SERVO_PORTE_DISTRIBUTION 26

// --- Capteur de niveau reservoir (2 fils denudes, detection par continuite) ---
// Deplace sur GPIO22 : GPIO15 (MTDO) est une broche de "strapping" qui peut
// interferer avec la communication SPI vers la puce flash pendant le
// televersement si du materiel externe y est deja connecte au demarrage.
#define PIN_NIVEAU_RESERVOIR    22

// --- Repulsion / signalisation ---
#define PIN_BUZZER              16
#define PIN_LED_VERTE           18   // s'allume quand la porte anti-nuisible est ouverte
#define PIN_LED_ROUGE           17   // s'allume en etat ALERTE
#define PIN_LED_RGB_R           19
#define PIN_LED_RGB_G           23
#define PIN_LED_RGB_B           21

// --- Pollinisation vibratile ---
#define PIN_VIBREUR              4

// =====================================================================
//  BIBLIOTHEQUES EXTERNES REQUISES (Gestionnaire de bibliotheques Arduino)
//   - ESP32Servo          (servomoteurs sur ESP32)
//   - DHT sensor library  (Adafruit, pour le DHT11)
//   - arduinoFFT          (analyse spectrale)
//  NB : l'API exacte d'arduinoFFT et de timerBegin() varie selon la version
//  installee - voir les commentaires dans frequence.cpp et microphone.cpp.
// =====================================================================

#endif
