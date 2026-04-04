# Personas et flux (BonAcheter)

## Personas

### Persona 1 — Parent en Montérégie (principal)
- **Rôle** : Gère les courses pour la maison, fait les achats en Montérégie et parfois dans la CMM (ex. Longueuil, Montréal).
- **Besoins** : Liste partagée avec le conjoint/les enfants, budget bi-hebdo ou mensuel, voir le total avec taxes (GST/QST), enregistrer où et à quel prix il a acheté.
- **Objectifs** : Ne pas dépasser le budget, ne pas oublier d’articles, comparer les prix entre magasins/régions.

### Persona 2 — Membre du foyer (secondaire)
- **Rôle** : Ajoute des articles à la liste, consulte la liste au magasin, peut enregistrer une course occasionnelle.
- **Besoins** : Accès simple à la liste, possibilité d’ajouter un article (manuel ou code-barres), être notifié si un article est en bas de la moyenne (post-MVP).

---

## Flux principaux

### Flux 1 — Premier lancement (onboarding)
1. Choix de la langue (FR / EN).
2. Créer un foyer (groupe) ou rejoindre un foyer (lien/code d’invitation).
3. Choisir la ou les régions d’achat (ex. Montérégie, CMM) et la ville.
4. (Optionnel) Définir le budget (bi-hebdo ou mensuel, montant).
5. Accès à la liste principale.

### Flux 2 — Consulter et modifier la liste
1. Ouvrir l’app → liste principale (articles, indicateur de budget).
2. Ajouter un article : manuel (nom, catégorie taxe, quantité) ou scanner code-barres/QR → pré-rempli (Open Food Facts).
3. Modifier / supprimer un article.
4. Les changements sont synchronisés en temps réel pour les autres membres.

### Flux 3 — Enregistrer une course (après les achats)
1. Depuis la liste ou un bouton « J’ai fait les courses ».
2. Sélectionner les articles achetés, saisir le prix payé par article (optionnel par ligne), le magasin, la date.
3. Voir le total du jour (sous-total + taxes).
4. Soumettre la course → mise à jour du budget et de l’historique.
5. (Post-MVP) Joindre une photo de la note et associer les lignes aux articles.

### Flux 4 — Gérer le budget
1. Depuis paramètres ou indicateur sur la liste.
2. Changer la période (bi-hebdo / mensuel) et le montant.
3. Voir le solde restant et l’historique des dépenses de la période.

### Flux 5 — Paramètres (région, langue, groupe)
1. Région(s) d’achat : ajouter/retirer Montérégie, CMM, ville.
2. Langue : FR / EN.
3. Groupe : inviter des membres, quitter le foyer.

---

## Règles métier (rappel)

- **Taxes** : Chaque article a une catégorie (zero-rated ou taxable). Par défaut : aliment de base = 0 %, autres = 14,975 % (GST+QST). Total du jour = somme des (prix × quantité) + taxes calculées par ligne.
- **Budget** : Période = bi-hebdo ou mensuel. Le solde = budget − somme des courses enregistrées dans la période.
- **Liste** : Un seul foyer peut avoir plusieurs listes (ex. par magasin ou par semaine) si besoin ; MVP peut commencer avec une liste par foyer.
