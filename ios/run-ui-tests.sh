#!/usr/bin/env bash
# Testes de UI / usabilidade (XCUITest). Deixe o Simulador visível para acompanhar os gestos.
#
# Modo “assistir” (~1,2 s entre passos): já está activo abaixo (UI_TEST_DEMO_PACING=1).
# Para corrida rápida: UI_TEST_DEMO_PACING=0 ./run-ui-tests.sh
set -euo pipefail
cd "$(dirname "$0")"
SIM="${1:-iPhone 17}"
PACE="${UI_TEST_DEMO_PACING:-1}"

open -a Simulator 2>/dev/null || true
sleep 1

# Variáveis no processo do xcodebuild propagam para o XCTest runner (modo “assistir”).
env "UI_TEST_DEMO_PACING=$PACE" xcodebuild test \
  -scheme BonAcheter \
  -sdk iphonesimulator \
  -destination "platform=iOS Simulator,name=$SIM" \
  -only-testing:BonAcheterUITests
