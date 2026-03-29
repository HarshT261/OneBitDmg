#!/usr/bin/env bash
# One-shot macOS build: download llamacpp backend, verify BitNet is vendored in-repo, then produce .app + .dmg.
# Prerequisite: commit src-tauri/resources/bitnet-backend/ (see BUILD.txt + sync-bitnet-from-onebit-suite.sh).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

[[ "$(uname -s)" == "Darwin" ]] || { echo "This script is for macOS only."; exit 1; }

echo "==> Llama.cpp backend (downloaded; not the BitNet fork)"
make download-llamacpp-backend-if-exists

echo "==> Verify vendored bundles (BitNet must live under src-tauri/resources/bitnet-backend/)"
bash scripts/verify-standalone-bundles.sh

echo "==> Frontend + extensions + native deps"
yarn build:web
yarn build:icon
yarn copy:assets:tauri
yarn build:extensions:darwin

yarn download:bin
yarn build:mlx-server
yarn build:foundation-models-server
yarn build:cli

echo "==> Tauri universal binary + DMG"
yarn tauri build --target universal-apple-darwin

DMG=$(ls -1 "$ROOT/src-tauri/target/universal-apple-darwin/release/bundle/dmg/"*.dmg 2>/dev/null | head -1 || true)
if [[ -n "$DMG" ]]; then
  echo ""
  echo "Done. Install disk image:"
  echo "  $DMG"
else
  echo "Build finished; check src-tauri/target/universal-apple-darwin/release/bundle/"
fi
