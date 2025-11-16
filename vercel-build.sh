#!/usr/bin/env bash
set -euo pipefail

echo "=== Installing Flutter (stable) ==="
git clone --depth 1 -b stable https://github.com/flutter/flutter.git flutter
export PATH="$PWD/flutter/bin:$PATH"

echo "=== Flutter version ==="
flutter --version

echo "=== Enabling web support ==="
flutter config --enable-web

echo "=== Getting dependencies ==="
flutter pub get

echo "=== Building Flutter web (release) ==="
flutter build web --release

echo "=== Build complete. Output at build/web ==="


