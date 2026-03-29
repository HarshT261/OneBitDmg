#!/usr/bin/env bash
# One-shot macOS build: download llamacpp backend, verify BitNet is vendored in-repo, then produce .app + .dmg.
# Prerequisite: commit src-tauri/resources/bitnet-backend/ (see BUILD.txt + sync-bitnet-from-onebit-suite.sh).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:${PATH:-}"
hash -r
if [[ "$(command -v corepack 2>/dev/null || true)" == /usr/local/* ]]; then
  PATH="/opt/homebrew/bin:/opt/homebrew/sbin:/usr/bin:/bin"
  hash -r
fi

# Rust: Homebrew rustup is keg-only — must be before /opt/homebrew/bin. Also ~/.cargo/bin (rustup.rs install).
export PATH="/opt/homebrew/opt/rustup/bin:${HOME}/.cargo/bin:/opt/homebrew/bin:/opt/homebrew/sbin:${PATH:-}"
if [[ -f "${HOME}/.cargo/env" ]]; then
  # shellcheck source=/dev/null
  . "${HOME}/.cargo/env"
fi
hash -r
if ! command -v cargo >/dev/null 2>&1; then
  echo "cargo not found. On macOS with Homebrew run:" >&2
  echo "  brew install rust rustup && export PATH=\"/opt/homebrew/opt/rustup/bin:\$PATH\" && rustup default stable && rustup target add aarch64-apple-darwin x86_64-apple-darwin" >&2
  echo "Or install from https://rustup.rs/ (adds ~/.cargo/bin)." >&2
  exit 1
fi

# Prefer plain `yarn` when Corepack shims exist; otherwise delegate to corepack.
yrun() {
  if command -v yarn >/dev/null 2>&1; then
    yarn "$@"
  elif command -v corepack >/dev/null 2>&1; then
    corepack yarn "$@"
  else
    echo "No yarn. Run: ./scripts/yarn-here.sh install" >&2
    exit 1
  fi
}

[[ "$(uname -s)" == "Darwin" ]] || { echo "This script is for macOS only."; exit 1; }

echo "==> Llama.cpp backend (downloaded; not the BitNet fork)"
make download-llamacpp-backend-if-exists

echo "==> Verify vendored bundles (BitNet must live under src-tauri/resources/bitnet-backend/)"
bash scripts/verify-standalone-bundles.sh

echo "==> Tauri plugin JS, @janhq/core, and extensions (required before web-app Vite build)"
yrun build:tauri:plugin:api
yrun build:core
yrun build:extensions:darwin

echo "==> Web app + icons + assets"
yrun build:web
yrun build:icon
yrun copy:assets:tauri

yrun download:bin
yrun build:mlx-server
yrun build:foundation-models-server
yrun build:cli

echo "==> Tauri universal binary + DMG"
# Tauri 2.x maps env CI to --ci; CI=1 is invalid (expects true/false). Unset for local/IDE builds.
env -u CI -u GITHUB_ACTIONS yrun tauri build --target universal-apple-darwin

DMG=$(ls -1 "$ROOT/src-tauri/target/universal-apple-darwin/release/bundle/dmg/"*.dmg 2>/dev/null | head -1 || true)
if [[ -n "$DMG" ]]; then
  echo ""
  echo "Done. Install disk image:"
  echo "  $DMG"
else
  echo "Build finished; check src-tauri/target/universal-apple-darwin/release/bundle/"
fi
