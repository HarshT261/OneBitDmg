#!/usr/bin/env bash
# Copy BitNet llama-server + libs from OneBitAI_Suite into src-tauri/resources/bitnet-backend/
# (same layout as install_bundled_backend expects: version.txt, backend.txt, build/bin/llama-server)
#
# Set ONEBIT_SUITE to your OneBitAI_Suite tree, or pass the path as the first argument.
# After syncing, commit src-tauri/resources/bitnet-backend/ so the DMG works on any Mac without this folder.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="$ROOT/src-tauri/resources/bitnet-backend"

if [[ -n "${1:-}" ]]; then
  ONEBIT_SUITE="$1"
else
  ONEBIT_SUITE="${ONEBIT_SUITE:-}"
fi
VERSION_FILE="${VERSION:-onebit-suite-bitnet}"
BACKEND_FILE="${BACKEND:-mac-arm64-bitnet}"

die() { echo "sync-bitnet-from-onebit-suite: $*" >&2; exit 1; }

[[ -n "$ONEBIT_SUITE" ]] || die "Set ONEBIT_SUITE=/path/to/OneBitAI_Suite or run: $0 /path/to/OneBitAI_Suite"
[[ -d "$ONEBIT_SUITE" ]] || die "Suite not found: $ONEBIT_SUITE"

OS="$(uname -s)"
case "$OS" in
  Darwin)
    BIN_DIR="$ONEBIT_SUITE/bin/mac"
    SRC_SERVER="$BIN_DIR/llama-server-bitnet"
    ;;
  Linux)
    BIN_DIR="$ONEBIT_SUITE/bin/linux"
    SRC_SERVER="$BIN_DIR/llama-server-bitnet"
    ;;
  *)
    die "Only Darwin and Linux are supported by this script (got $OS)"
    ;;
esac

[[ -d "$BIN_DIR" ]] || die "Missing $BIN_DIR"
[[ -x "$SRC_SERVER" ]] || die "BitNet server not found or not executable: $SRC_SERVER (build the suite or use bin/mac from a full OneBitAI_Suite install)"

mkdir -p "$OUT/build/bin"

cp -f "$SRC_SERVER" "$OUT/build/bin/llama-server"
chmod +x "$OUT/build/bin/llama-server"

# Co-locate BitNet dylibs (macOS) or .so (Linux) if present
if [[ "$OS" == "Darwin" ]]; then
  for lib in libggml-bitnet.dylib libllama-bitnet.dylib; do
    if [[ -f "$BIN_DIR/$lib" ]]; then
      cp -f "$BIN_DIR/$lib" "$OUT/build/bin/"
    fi
  done
else
  for lib in libggml-bitnet.so libllama-bitnet.so libggml.so libllama.so; do
    if [[ -f "$BIN_DIR/$lib" ]]; then
      cp -f "$BIN_DIR/$lib" "$OUT/build/bin/"
    fi
  done
fi

printf '%s' "$VERSION_FILE" > "$OUT/version.txt"
printf '%s' "$BACKEND_FILE" > "$OUT/backend.txt"

echo "Synced BitNet backend from: $BIN_DIR"
echo "  → $OUT"
echo "  version.txt=$(cat "$OUT/version.txt")  backend.txt=$(cat "$OUT/backend.txt")"
echo ""
echo "Next: git add src-tauri/resources/bitnet-backend && git commit -m 'bundle BitNet backend for standalone DMG'"
echo "Optional web agent (same suite): cd \"$ONEBIT_SUITE/webtools\" && ./start_webtools.sh"
