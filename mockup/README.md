# Prototype BonAcheter (mockup)

Prototype HTML/CSS cliquable pour revue avant développement. Aucun outil payant requis.

## Comment l’ouvrir

1. Ouvrir `index.html` dans un navigateur (double-clic ou `open index.html` dans le terminal).
2. Pour une vue « téléphone », réduire la largeur de la fenêtre (ou utiliser les DevTools en mode mobile, 375px).

## Navigation

- **Landing** : « Commencer » → Onboarding ; « J'ai déjà un compte » → Dashboard.
- **Dashboard** : « Ma liste », « Budget », « Dernière course », « Paramètres ».
- **Onboarding** : Langue → Foyer (créer/rejoindre) → Région → Dashboard.
- **Liste** : Cliquer sur la barre de budget pour aller à l’écran Budget ; « + Ajouter un article » → formulaire ; « J’ai fait les courses » → enregistrer une course.
- **Ajouter un article** : « Scanner code-barres » → Scanner (mock) ; « Enregistrer » → Liste.
- **Budget / Enregistrer course / Paramètres** : « ← » ou « Enregistrer » → Dashboard. Déconnexion → Landing.

## Fichiers

- `index.html` : toutes les écrans et la navigation par hash (`#screen-*`).
- `styles.css` : styles (mobile-first, thème vert Québec).

## Spécifications détaillées

Voir `docs/design/personas-flows.md` et `docs/design/screens.md` dans le repo.
