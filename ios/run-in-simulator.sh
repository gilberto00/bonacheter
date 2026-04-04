#!/usr/bin/env bash
# Build BonAcheter and install/launch on an iOS Simulator (CLI alternative to Xcode ▶ when
# destination was left on "Any iOS Device").
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT"

SIM_NAME="${1:-iPhone 17}"
DERIVED="/tmp/BonAcheterDerivedData"
BUNDLE_ID="com.bonacheter.app"

if ! xcrun simctl list devices available 2>/dev/null | grep -q "$SIM_NAME"; then
  echo "Simulador '$SIM_NAME' não encontrado. Instale runtimes em Xcode → Settings → Platforms."
  echo "Dispositivos disponíveis:"
  xcrun simctl list devices available | grep -E "iPhone|iPad" || true
  exit 1
fi

UDID=$(xcrun simctl list devices available | grep "$SIM_NAME (" | head -1 | sed -E 's/.*\(([0-9A-F-]+)\).*/\1/')
if [[ -z "$UDID" || "$UDID" == *"("* ]]; then
  echo "Não foi possível obter o UDID do simulador."
  exit 1
fi

echo "→ Compilando para $SIM_NAME ($UDID)…"
xcodebuild -scheme BonAcheter \
  -destination "platform=iOS Simulator,id=$UDID" \
  -derivedDataPath "$DERIVED" \
  -quiet build

APP="$DERIVED/Build/Products/Debug-iphonesimulator/BonAcheter.app"
if [[ ! -d "$APP" ]]; then
  echo "Build concluído mas .app não encontrado em $APP"
  exit 1
fi

echo "→ Iniciando simulador e app…"
xcrun simctl boot "$UDID" 2>/dev/null || true
open -a Simulator
sleep 1
xcrun simctl install "$UDID" "$APP"
xcrun simctl launch "$UDID" "$BUNDLE_ID"
echo "→ Pronto."
