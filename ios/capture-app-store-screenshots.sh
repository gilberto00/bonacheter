#!/usr/bin/env bash
# Gera PNGs para o App Store Connect (6,7" ou dispositivo compatível com os tamanhos pedidos pela Apple).
# Uso: ./capture-app-store-screenshots.sh [nome do simulador]
# Ex.: ./capture-app-store-screenshots.sh "iPhone 16 Pro Max"
set -euo pipefail
cd "$(dirname "$0")"

SIM="${1:-iPhone 17 Pro Max}"
OUT="$(pwd)/app-store-screenshots/generated"
mkdir -p "$OUT"
# Same path via home so o teste no simulador encontra via SIMULATOR_HOST_HOME/BonAcheterAppStoreScreenshots
mkdir -p "$HOME/BonAcheterAppStoreScreenshots"
rm -f "$HOME/BonAcheterAppStoreScreenshots"/*.png 2>/dev/null || true

if ! xcrun simctl list devices available 2>/dev/null | grep -q "$SIM"; then
  echo "Simulador '$SIM' não encontrado. Disponíveis:"
  xcrun simctl list devices available | grep -E "iPhone|iPad" || true
  exit 1
fi

open -a Simulator 2>/dev/null || true
sleep 1

echo "→ A gerar screenshots em: $OUT"
echo "→ Simulador: $SIM"

export APP_STORE_SCREENSHOT_DIR="$OUT"
export UI_TEST_DEMO_PACING=0
xcodebuild test \
  -scheme BonAcheter \
  -sdk iphonesimulator \
  -destination "platform=iOS Simulator,name=$SIM" \
  -only-testing:BonAcheterUITests/AppStoreScreenshotsUITests/testCaptureAppStoreScreenshots \
  2>&1 | tee /tmp/bonacheter-screenshots.log

echo ""
if [[ -d "$HOME/BonAcheterAppStoreScreenshots" ]]; then
  cp -f "$HOME/BonAcheterAppStoreScreenshots"/*.png "$OUT/" 2>/dev/null || true
fi
# App Store Connect (6,5"/6,7") exige um destes: 1242×2688, 1284×2778, etc. O iPhone 17 Pro Max gera 1320×2868.
echo "→ A redimensionar para 1284×2778 (retrato, aceite pelo ASC)…"
for f in "$OUT"/*.png; do
  [[ -f "$f" ]] || continue
  sips -z 2778 1284 "$f" --out "$f" >/dev/null
done
echo "→ Ficheiros em $OUT :"
ls -la "$OUT" 2>/dev/null || true

for f in "$OUT"/*.png; do
  [[ -f "$f" ]] || continue
  echo -n "$(basename "$f"): "
  sips -g pixelWidth -g pixelHeight "$f" 2>/dev/null | grep pixel | tr '\n' ' ' || true
  echo ""
done

echo "→ Concluído. Arrasta os PNG para App Store Connect (secção Screenshots iPhone)."
