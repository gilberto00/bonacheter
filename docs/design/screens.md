# Spécification des écrans (BonAcheter) — MVP

Chaque écran : objectif, champs, boutons, états (vide, erreur). Texte bilingue FR/EN à prévoir.

---

## 0. Landing (première vue, non connecté)
- **Objectif** : Présenter l’app et orienter vers inscription ou connexion.
- **Contenu** :
  - Titre « BonAcheter », courte description (liste partagée, budget, taxes Québec, Montérégie/CMM).
  - CTA principal : « Commencer » (ou « Get started ») → onboarding (créer un compte).
  - Lien secondaire : « J’ai déjà un compte » → connexion (après connexion → Dashboard).
- **Actions** : Clic sur « Commencer » → écran Choix de la langue (ou Foyer) ; clic sur « J’ai déjà un compte » → écran Connexion ou directement Dashboard si connexion simplifiée.
- **États** : Aucun état vide critique.

---

## 0b. Dashboard (accueil après connexion)
- **Objectif** : Résumé rapide et accès aux principales fonctions (liste, budget, dernière course, paramètres).
- **Contenu** :
  - Bloc résumé : budget de la période (ex. « 80 $ restants / 200 $ »), barre de progression, période (bi-hebdo/mensuel).
  - Cartes / lignes cliquables : « Ma liste » → Liste ; « Budget » → Budget ; « Dernière course » → Enregistrer une course (avec aperçu, ex. « IGA — 45,20 $ ») ; « Paramètres » → Paramètres.
- **Actions** : Chaque carte mène à l’écran correspondant. Pas de bouton « Retour » (Dashboard = racine de l’app après login).
- **États** : Première utilisation : pas de « Dernière course » ou afficher « Aucune course enregistrée ».

---

## 1. Onboarding — Choix de la langue
- **Objectif** : Choisir la langue au premier lancement.
- **Contenu** : Titre « BonAcheter », deux boutons ou sélecteur : Français / English.
- **Actions** : Clic sur une langue → sauvegarder préférence, passer à l’écran suivant (créer/rejoindre foyer).
- **États** : Aucun état vide critique.

---

## 2. Onboarding — Créer ou rejoindre un foyer
- **Objectif** : Créer un nouveau groupe (foyer) ou rejoindre un groupe existant.
- **Contenu** :
  - Bouton « Créer un foyer » → formulaire court : nom du foyer (optionnel).
  - Bouton « Rejoindre un foyer » → champ : code ou lien d’invitation.
- **Champs** : Nom du foyer (texte, optionnel) ; Code d’invitation (texte, obligatoire pour rejoindre).
- **Actions** : Valider → créer le foyer ou rejoindre ; en cas d’erreur (code invalide), afficher message.
- **États** : Erreur « Code invalide » si rejoindre avec code incorrect.

---

## 3. Onboarding — Région(s) d’achat
- **Objectif** : Définir où l’utilisateur fait ses courses (pays, province, région, ville).
- **Contenu** :
  - Pays : Canada (présélectionné).
  - Province : Québec (présélectionné).
  - Région(s) : cases à cocher ou multi-select — Montérégie, CMM (et éventuellement autres régions QC).
  - Ville : liste ou champ selon la région (ex. Longueuil, Saint-Jean-sur-Richelieu, Montréal).
- **Actions** : Suivant → sauvegarder et aller au Dashboard (ou à la liste si pas de dashboard).
- **Règles** : Au moins une région et une ville sélectionnées.

---

## 4. Liste principale
- **Objectif** : Afficher la liste partagée et le budget restant ; permettre d’ajouter/modifier/supprimer des articles.
- **Contenu** :
  - En-tête : nom du foyer, indicateur de budget (ex. « 120 $ / 200 $ » ou barre de progression), période (bi-hebdo/mensuel).
  - Liste d’articles : nom, quantité, unité, catégorie taxe (icône ou badge 0 % / taxé), optionnellement code-barres.
  - Filtres (optionnel MVP) : tous / à acheter / achetés récemment.
- **Actions** :
  - Clic sur un article → éditer (nom, quantité, catégorie taxe).
  - Bouton « Ajouter » → écran Ajouter un article (manuel ou scanner).
  - Bouton « J’ai fait les courses » ou « Enregistrer une course » → écran Enregistrer une course.
  - Menu ou icône Paramètres → Paramètres.
- **États** : Liste vide → message « Aucun article. Ajoutez un article ou scannez un code-barres. »

---

## 5. Ajouter / Modifier un article
- **Objectif** : Saisir un article manuellement ou après un scan.
- **Champs** :
  - Nom (texte, obligatoire).
  - Quantité (nombre, défaut 1).
  - Unité (optionnel : pièce, L, kg, etc.).
  - Catégorie de taxe : Zero-rated (0 %) / Taxable (14,975 %) — sélecteur ou boutons.
  - Code-barres (affiché en lecture seule si rempli par scan ; optionnel en manuel).
- **Actions** :
  - « Scanner » → ouvrir l’écran Scanner (caméra) ; au retour, pré-remplir nom et éventuellement catégorie.
  - « Enregistrer » → ajouter ou mettre à jour l’article et revenir à la liste.
  - « Annuler » → revenir sans sauvegarder.
- **États** : Erreur « Nom requis » si enregistrer sans nom.

---

## 6. Scanner (code-barres / QR)
- **Objectif** : Lire un code-barres ou QR pour identifier le produit (Open Food Facts).
- **Contenu** : Vue caméra avec cadre de scan ; après lecture : appel API Open Food Facts, affichage du nom (et catégorie si disponible).
- **Actions** :
  - « Utiliser ce produit » → remplir l’écran Ajouter un article avec les infos et revenir.
  - « Saisir manuellement » → aller à Ajouter un article sans pré-remplissage.
- **États** : Produit non trouvé → message « Produit non trouvé. Saisir manuellement ? »

---

## 7. Définir / Modifier le budget
- **Objectif** : Choisir la période et le montant du budget.
- **Champs** :
  - Période : Bi-hebdomadaire / Mensuel (segmented control ou boutons).
  - Montant (nombre, devise CAD).
- **Contenu** : Afficher le solde actuel de la période (budget − dépenses enregistrées).
- **Actions** : « Enregistrer » → sauvegarder et revenir ; « Annuler » → revenir sans sauvegarder.
- **États** : Montant invalide (≤ 0) → message d’erreur.

---

## 8. Enregistrer une course
- **Objectif** : Saisir les articles achetés, les prix, le magasin et voir le total avec taxes.
- **Contenu** :
  - Liste des articles de la liste (cases à cocher) ; pour chaque article coché : champ « Prix payé » (optionnel), quantité achetée.
  - Champ « Magasin » (texte).
  - Date (défaut : aujourd’hui).
  - Bloc récap : Sous-total, Taxes (détail 0 % vs 14,975 % si utile), Total.
- **Actions** :
  - « Enregistrer la course » → sauvegarder, mettre à jour le budget et l’historique, revenir à la liste (marquer les articles comme achetés ou les retirer selon la logique choisie).
  - « Annuler » → revenir sans sauvegarder.
- **États** : Aucun article coché → désactiver « Enregistrer » ou message « Sélectionnez au moins un article ».

---

## 9. Paramètres
- **Objectif** : Gérer région, langue, notifications, foyer.
- **Contenu** :
  - Région(s) d’achat : même logique qu’onboarding (Montérégie, CMM, ville).
  - Langue : FR / EN.
  - Notifications : activer/désactiver (alertes budget, rappels, etc.).
  - Foyer : nom du foyer, inviter (partager lien/code), quitter le foyer.
- **Actions** : Sauvegarder pour chaque section ou navigation simple sans sauvegarde explicite (sauvegarde à la sortie).

---

## 10. (Post-MVP) Note fiscale + association
- Envoyer une photo de la note ; OCR extrait les lignes ; l’utilisateur associe chaque ligne à un article de la liste (ou crée un article). Détail à préciser en phase 2.

---

## Résumé des écrans pour le prototype cliquable
1. **Landing** : Commencer → Onboarding ; J’ai déjà un compte → Dashboard.
2. **Dashboard** : Ma liste, Budget, Dernière course, Paramètres.
3. Onboarding : langue → foyer → région → Dashboard.
4. Liste principale (accessible depuis Dashboard).
5. Ajouter un article (avec lien « Scanner »).
6. Scanner (mock : bouton « Simuler un scan »).
7. Budget.
8. Enregistrer une course.
9. Paramètres (Déconnexion → Landing).
