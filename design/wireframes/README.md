# Wireframes BonAcheter — Import dans Penpot

Tous les écrans sont en **SVG 375×812** (format mobile), style wireframe (traits, labels, pas de couleurs de marque).

**Le premier écran est la Landing (page d'accueil)** : `01-landing.svg` — titre BonAcheter, description, boutons « Commencer » et « J'ai déjà un compte ». Ce wireframe a une étiquette en haut : « [ Landing — Page d'accueil ] ».

## Fichiers

| Fichier | Écran |
|---------|--------|
| **`01-landing.svg`** | **Landing (page d'accueil)** — hero, CTA « Commencer », « J'ai déjà un compte » |
| `02-dashboard.svg` | Dashboard — résumé budget, liens Ma liste, Budget, Dernière course, Paramètres |
| `03-onboarding-langue.svg` | Onboarding — choix FR / EN |
| `04-onboarding-foyer.svg` | Onboarding — créer ou rejoindre un foyer |
| `05-onboarding-region.svg` | Onboarding — région(s) et ville |
| `06-liste.svg` | Liste principale + barre budget + actions |
| `07-ajouter-article.svg` | Nouvel article (nom, quantité, taxe, lien scanner) |
| `08-scanner.svg` | Scanner code-barres / QR (mock) |
| `09-budget.svg` | Définir budget (période, montant) |
| `10-enregistrer-course.svg` | Enregistrer une course (magasin, articles, totaux) |
| `11-parametres.svg` | Paramètres (région, langue, foyer, déconnexion) |

## Important : format d'import Penpot

**« Import files »** dans Penpot n'accepte **pas** les fichiers `.svg` seuls. Il accepte uniquement :
- des fichiers **.penpot** (format natif), ou
- des archives **.zip** au format legacy (SVG + JSON, export Penpot 2.3 ou antérieur).

Les `.svg` de ce dossier ne peuvent donc pas être importés directement via « Import files ».

## Deux façons d'utiliser ces wireframes

### Option A — Prototype HTML (recommandé pour revue)

Ouvrir **`../mockup/index.html`** dans le navigateur. Vous avez déjà tout le flux (Landing, Dashboard, Liste, etc.) en cliquable, sans Penpot. Idéal pour valider le parcours avant de coder.

### Option B — Coller les SVG dans Penpot (pour éditer dans Penpot)

1. Aller sur [penpot.app](https://penpot.app), créer un projet et un fichier.
2. Pour chaque écran : créer un **frame (artboard)** 375×812 (outil Frame ou raccourci B).
3. Ouvrir **`copy-svg-to-penpot.html`** (dans ce dossier) dans **Chrome**. Si les boutons « Copier » ne chargent pas les SVG (page ouverte en `file://`), lancer un serveur local dans ce dossier : `python3 -m http.server 8080` puis aller sur `http://localhost:8080/copy-svg-to-penpot.html`.
4. Pour chaque wireframe : cliquer sur **« Copier le SVG »** à côté du nom de l'écran.
5. Dans Penpot, sélectionner le frame, puis **Ctrl+V (Cmd+V)** : le SVG est collé en vecteurs dans le frame.
6. Renommer le frame (ex. « Landing », « Dashboard »). Répéter pour les 11 écrans.

Utiliser Chrome pour le copier-coller : sous Firefox, le SVG peut être collé en image raster au lieu de vecteurs.

## Organiser les pages (recommandé)

- **Page 1 — Landing & Auth** : `01-landing`, `03-onboarding-langue`, `04-onboarding-foyer`, `05-onboarding-region`.
- **Page 2 — App** : `02-dashboard`, `06-liste`, `07-ajouter-article`, `08-scanner`, `09-budget`, `10-enregistrer-course`, `11-parametres`.

Renommer les frames pour plus de clarté (ex. « Landing », « Dashboard », « Liste »).

## Flux prototype (liens entre frames)

Pour avoir un prototype cliquable dans Penpot :

1. Passer en mode **Prototype** (panneau de droite).
2. Sélectionner un frame, puis dessiner des **zones de lien** (hotspots) sur les boutons / zones cliquables.
3. Pour chaque hotspot, définir l’**action** : « Navigate to » → frame cible.

**Flux à relier :**

- **Landing** : « Commencer » → Onboarding Langue (ou Foyer) ; « J'ai déjà un compte » → Dashboard (ou écran Connexion si vous l’ajoutez).
- **Onboarding Langue** : Français / English → Foyer.
- **Onboarding Foyer** : « Créer un foyer » / « Rejoindre » → Région.
- **Onboarding Région** : « Continuer » → Dashboard.
- **Dashboard** : « Ma liste » → Liste ; « Budget » → Budget ; « Dernière course » → Enregistrer course ; « Paramètres » → Paramètres.
- **Liste** : « + Ajouter un article » → Ajouter article ; « J'ai fait les courses » → Enregistrer course ; barre budget → Budget ; ⚙ → Paramètres.
- **Ajouter article** : « Scanner code-barres » → Scanner ; « Enregistrer » → Liste.
- **Scanner** : « Simuler un scan réussi » → Ajouter article.
- **Budget** : « Enregistrer » → Liste (ou Dashboard).
- **Enregistrer course** : « Enregistrer la course » → Liste (ou Dashboard).
- **Paramètres** : « ← » → Liste ou Dashboard ; « Déconnexion » → Landing.

Après avoir relié les frames, utiliser **Preview** dans Penpot pour parcourir le flux comme un prototype.
