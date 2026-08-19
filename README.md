# Tranom-boliko — JGTech (version Processing, complète)

Traduction **Processing (Java mode), modulaire**, de l'application web
d'origine (React/JSX + backend propriétaire "base44"), avec **toutes les
fonctionnalités demandées rendues réelles**.

## Comment lancer

1. Ouvrez `TranomBoliko/TranomBoliko.pde` avec l'application **Processing**
   (processing.org). Les autres `.pde` du dossier s'ouvrent automatiquement
   comme onglets.
2. Cliquez sur ▶ (Exécuter).
3. Connexion Internet nécessaire pour la météo et la géolocalisation.

## Fonctionnalités réelles

### Comptes utilisateurs (nouveau)
Inscription / connexion locale, mot de passe **hashé SHA-256 + sel**
(jamais stocké en clair). Chaque compte a ses propres tâches, dépenses,
récoltes, ventes et notifications, séparées dans
`data/users/<votre_nom>/`.

### CRUD complet partout (nouveau)
Tâches, dépenses, récoltes, ventes, marchés : **ajout, modification et
suppression** sont maintenant tous implémentés (auparavant seul l'ajout
existait).

### Récoltes — page dédiée (nouveau)
Écran complet accessible depuis "Espaces utilisateurs" → "Gérer mes
récoltes" : ajout / édition / suppression, totaux calculés.

### Marchés éditables (nouveau)
Bouton "+ Ajouter un marché" et actions "Éditer / Supprimer" sur chaque
ligne. Stocké dans `data/marches.csv`, partagé entre tous les comptes.

### Géolocalisation réelle (nouveau)
Position approximative obtenue via votre IP publique (ip-api.com, gratuit,
sans clé), puis **vraie distance** calculée avec la formule de haversine
vers les coordonnées GPS réelles de chaque marché, pour le tri
"Autour de moi".

### Notifications (nouveau)
Cloche dans la barre de navigation : journal d'activité réel et persistant
(tâche ajoutée, vente enregistrée, marché modifié...), avec compteur de
non-lus.

### Page Aide (nouveau)
FAQ complète expliquant chaque fonctionnalité.

### Capteurs matériels réels (nouveau, optionnel)
Si un **ESP32/Arduino** est branché en USB et envoie des lignes au format :
```
temperature,humidite_air,humidite_sol,luminosite,pompe,engrais,porte,batterie,consommation
24.6,68,42,850,1,0,0,87,1.24
```
...le tableau de bord affiche ces **vraies valeurs**, avec l'étiquette
"Connecté (matériel réel)". Sans capteur branché, l'application continue
de fonctionner avec la simulation d'origine, clairement indiquée
("Simulation").
Pour préciser le port, créez `data/serial_config.txt` avec le nom du port
(ex: `COM3` ou `/dev/ttyUSB0`) sur la première ligne.

### Historique réel des capteurs (nouveau)
Chaque lecture (réelle ou simulée) est journalisée dans
`data/users/<vous>/sensor_history.csv`. Le graphique "Évolution des
paramètres" trace cet historique réel dès que suffisamment de points sont
collectés (sinon un exemple est affiché, clairement étiqueté).

### Envoi d'email réel (nouveau, optionnel)
Le formulaire de contact enregistre toujours le message localement. Pour un
**vrai envoi SMTP**, créez `data/smtp_config.txt` :
```
smtp.gmail.com
465
votre_adresse@gmail.com
votre_mot_de_passe_application
```
(utilisez un "mot de passe d'application" Google, pas votre mot de passe
normal). Sans ce fichier, aucune fausse confirmation d'envoi n'est
affichée — l'appli indique honnêtement "enregistré localement".

### Météo réelle
API publique **Open-Meteo**, aucune clé requise, rafraîchie toutes les
15 minutes.

### Fenêtre redimensionnable (nouveau)
`surface.setResizable(true)` — la mise en page s'adapte à la largeur/hauteur.

## Limite structurelle honnête : la synchro cloud

Une vraie synchronisation multi-appareils nécessite un **serveur hébergé**
(base de données distante, API, authentification réseau) — c'est
exactement ce que faisait `base44` dans le projet d'origine, via un service
tiers privé auquel je n'ai pas accès et que je ne peux pas provisionner
depuis ce sketch local.

**Solution pratique et réelle que vous pouvez utiliser dès maintenant** :
déplacez tout le dossier `data/` dans un dossier **Dropbox / Google
Drive / OneDrive** synchronisé. Comme tout est stocké en fichiers texte
simples, ils se synchroniseront automatiquement entre vos appareils —
sans écrire une seule ligne de serveur.

## Structure des fichiers

```
TranomBoliko/
├── TranomBoliko.pde       Point d'entrée (setup/draw/routing)
├── 00_Auth.pde             Comptes utilisateurs (hash SHA-256 + sel)
├── 00b_Login.pde           Écran de connexion / inscription
├── 01_Navbar.pde           Barre de navigation + cloche + menu utilisateur
├── 02_UIWidgets.pde        Palette, cartes, boutons, icônes vectorielles
├── 03_TextField.pde        Champ de saisie texte réutilisable
├── 04_DataModel.pde        Classes de données + persistance CSV par utilisateur
├── 05_WeatherService.pde   Appel RÉEL à l'API Open-Meteo
├── 06_Accueil.pde          Page d'accueil
├── 07_Dashboard.pde        Tableau de bord (capteurs réels/simulés + météo réelle)
├── 08_Espaces.pde          Tâches / dépenses (CRUD complet)
├── 09_Vente.pde            Marchés éditables + distance réelle
├── 10_VentesUser.pde       Mes ventes (CRUD complet)
├── 11_Meteo.pde            Page météo détaillée
├── 12_Contact.pde          Formulaire de contact + envoi SMTP réel optionnel
├── 13_Recoltes.pde         Récoltes (CRUD complet)
├── 14_Help.pde             Page d'aide / FAQ
├── 15_Notifications.pde    Panneau de notifications (cloche)
├── 16_Geolocation.pde      Géolocalisation IP réelle + haversine
├── 17_Serial.pde           Intégration matérielle réelle (ESP32/Arduino)
├── 18_SmtpEmail.pde        Envoi d'email réel par SMTP (optionnel)
└── data/                   Créé automatiquement : users.csv, marches.csv,
                             users/<compte>/*.csv, smtp_config.txt (à créer),
                             serial_config.txt (à créer)
```

## Ce qui reste, par nature, hors de portée d'un sketch local

- Un vrai serveur cloud multi-utilisateurs simultané (voir ci-dessus).
- Un vrai capteur physique sans matériel réellement branché (le protocole
  est prêt et fonctionnel, mais je ne peux pas fabriquer un ESP32).
- L'envoi d'email sans vos propres identifiants (je n'ai et ne peux pas
  avoir accès à votre compte email).
