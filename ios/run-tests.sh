#!/usr/bin/env bash
# Run BonAcheter unit tests on the iOS Simulator (same idea as Xcode Product → Test).
set -euo pipefail
cd "$(dirname "$0")"
SIM="${1:-iPhone 17}"
exec xcodebuild test \
  -scheme BonAcheter \
  -sdk iphonesimulator \
  -destination "platform=iOS Simulator,name=$SIM" \
  -only-testing:BonAcheterTests
