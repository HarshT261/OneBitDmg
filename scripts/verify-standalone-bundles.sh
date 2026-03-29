#!/usr/bin/env bash
# Fail fast if macOS bundle resources required for a standalone DMG are missing.
# Run after: make download-llamacpp-backend-if-exists  and  vendoring bitnet-backend (see BUILD.txt).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

die() { echo "verify-standalone-bundles: $*" >&2; exit 1; }

[[ "$(uname -s)" == "Darwin" ]] || { echo "OK (skipped: not macOS)"; exit 0; }

LLAMA="src-tauri/resources/llamacpp-backend/build/bin/llama-server"
BITNET="src-tauri/resources/bitnet-backend/build/bin/llama-server"
BITNET_VER="src-tauri/resources/bitnet-backend/version.txt"

[[ -f "$LLAMA" && -x "$LLAMA" ]] || die "Missing stock llama backend. Run: make download-llamacpp-backend"

[[ -f "$BITNET_VER" ]] || die "Missing $BITNET_VER — copy BitNet into the repo (see src-tauri/resources/bitnet-backend/BUILD.txt)"
[[ -f "$BITNET" && -x "$BITNET" ]] || die "Missing BitNet llama-server at $BITNET — run scripts/sync-bitnet-from-onebit-suite.sh once, then commit this folder"

echo "Standalone bundles OK:"
echo "  $LLAMA"
echo "  $BITNET ($(wc -c < "$BITNET" | tr -d ' ') bytes)"
echo "  version $(tr -d '\n' < "$BITNET_VER")/$(tr -d '\n' < src-tauri/resources/bitnet-backend/backend.txt)"
