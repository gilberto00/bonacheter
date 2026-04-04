# BonAcheter — App iPhone (wireframe / prototype)

App iOS em SwiftUI que serve de **wireframe navegável** no Xcode e no simulador (ou dispositivo).

## Como abrir e rodar

1. Abra o projeto no Xcode (carrega o alvo **BonAcheter**, não só a tela de boas-vindas):
   ```bash
   open -a Xcode ios/BonAcheter.xcodeproj
   ```
   A partir da raiz do repositório `BonAcheter`. Alternativa: `open ios/BonAcheter.xcodeproj` ou duplo clique em `ios/BonAcheter.xcodeproj` no Finder.

2. Selecione um simulador (ex.: iPhone 17, iPhone 16e) no menu de destino no topo do Xcode.

3. Rode o app com **Cmd+R** ou clique no botão Play.

### “A build only device cannot be used to run this target”

Isso aparece quando o destino ao lado do botão **Run** está em **Any iOS Device (arm64)**. Esse destino só serve para arquivo/genérico, **não** para executar.

**Correção no Xcode:** clique no menu de destino (ao lado de “BonAcheter”) e escolha um **simulador**, por exemplo **iPhone 17** ou **iPhone 16e**. Depois pressione **Cmd+R** de novo.

**Pelo terminal** (compila, abre o Simulator e lança o app):

```bash
chmod +x ios/run-in-simulator.sh
./ios/run-in-simulator.sh
# ou outro modelo: ./ios/run-in-simulator.sh "iPhone 17 Pro"
```

## Fluxo do app

- **Landing** : "Commencer" → onboarding (Langue → Foyer → Région) ; "J'ai déjà un compte" → feuille **Connexion** (email/mot de passe stockés sur l’appareil, MVP).
- **Onboarding** : escolha de idioma (FR/EN), **Créer un foyer** (génère un code d’invitation) ou **Rejoindre** (code ≥ 4 caractères), região (Montérégie, CMM) e cidade.
- **Dashboard** (tab Accueil) : resumo do budget, atalhos para Ma liste, Budget, Dernière course, Paramètres.
- **Liste** (tab Liste) : lista de artigos, barra de budget, "+ Ajouter un article", "J'ai fait les courses", engrenagem → Paramètres.
- **Ajouter article** : nom, code-barres (lookup **Open Food Facts**), quantité, unité, taxe (0% ou 14,98%), Scanner, Enregistrer.
- **Scanner** : saisie manuelle du code (≥ 8 chiffres) + recherche OFF, ou simulation (EAN d’exemple). La caméra pourra remplacer la saisie plus tard.
- **Budget** : période (Bi-hebdo / Mensuel), montant CAD.
- **Enregistrer la course** : magasin, articles cochés avec prix, sous-total / taxes / total.
- **Paramètres** : région, langue, **code d’invitation** (copier / partager), communauté, Déconnexion → Landing (efface l’email MVP).

## Testes (unitários)

No Xcode: **Product → Test** (Cmd+U), com um **simulador** selecionado (não “Any iOS Device”).

Pelo terminal:

```bash
./ios/run-tests.sh
# ou: ./ios/run-tests.sh "iPhone 17 Pro"
```

Ou diretamente:

```bash
cd ios && xcodebuild test -scheme BonAcheter -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:BonAcheterTests
```

O target **BonAcheterTests** cobre `ListItem` (Codable), `OpenFoodFactsClient` (validação de código), `AppState` (foyer, compras, histórico), `GroceryUnitCatalog`, idioma e `LocalOnlyListSyncService`.

## Testes de UI / usabilidade (para ver no Simulador)

O target **BonAcheterUITests** percorre fluxos reais: landing → onboarding (idioma, foyer, região) → lista → adicionar artigo; login (sheet cancelar); lista → definições.

**Para assistir:** abra o **Simulator** (ou use `./run-ui-tests.sh`, que tenta abri-lo), escolha o **iPhone 17** (ou outro) como destino e corra:

```bash
chmod +x ios/run-ui-tests.sh
UI_TEST_DEMO_PACING=1 ./ios/run-ui-tests.sh
```

`UI_TEST_DEMO_PACING=1` adiciona ~1,2 s entre passos para conseguir acompanhar os toques. Para execução rápida: `UI_TEST_DEMO_PACING=0 ./ios/run-ui-tests.sh`.

No **Xcode:** selecione o simulador → **Product → Test** (⌘U) e abra a janela do Simulator por cima. Opcional: em **Edit Scheme → Test → Arguments → Environment**, adicione `UI_TEST_DEMO_PACING` = `1`.

CLI directo:

```bash
cd ios && UI_TEST_DEMO_PACING=1 xcodebuild test -scheme BonAcheter -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:BonAcheterUITests
```

## Estrutura

- `BonAcheter/` — código fonte SwiftUI.
- `BonAcheterTests/` — testes unitários XCTest.
- `BonAcheterUITests/` — testes de UI (usabilidade / fluxos).
- `BonAcheter.xcodeproj` — projeto Xcode.
- Estado global em `AppState` (@Observable). Sync : `ListSyncServicing` + `LocalOnlyListSyncService` (no-op) ; voir `docs/architecture/MVP-BACKEND.md` pour Supabase Realtime.

## Requisitos

- Xcode 15+ (testado com Xcode que suporta iOS 17).
- Deployment target: iOS 17.0.
