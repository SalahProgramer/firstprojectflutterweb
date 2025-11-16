#!/usr/bin/env bash
set -euo pipefail

echo "=== Installing Flutter (stable) ==="
git clone --depth 1 -b stable https://github.com/flutter/flutter.git flutter
FLUTTER="$PWD/flutter/bin/flutter"

echo "=== Flutter version ==="
$FLUTTER --version

echo "=== Enabling web support ==="
$FLUTTER config --enable-web
echo "=== Precaching web artifacts ==="
$FLUTTER precache --web

echo "=== Getting dependencies ==="
$FLUTTER pub get

echo "=== Building Flutter web (release) ==="
$FLUTTER build web --release --no-tree-shake-icons

echo "=== Build complete. Output at build/web ==="

echo "=== Syncing build/web -> web (for Vercel outputDirectory) ==="
rm -rf web
mkdir -p web
cp -R build/web/. web/
echo "=== Sync complete. Final output at web ==="

