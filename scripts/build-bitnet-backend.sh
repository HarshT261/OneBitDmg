#!/usr/bin/env bash
# Populate src-tauri/resources/bitnet-backend from either:
#   - ONEBIT_SUITE set → OneBitAI_Suite prebuilt binaries (bin/mac/llama-server-bitnet + dylibs)
#   - else → build from a microsoft/BitNet clone (setup_env.py).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"

if [[ -n "${ONEBIT_SUITE:-}" ]]; then
  export ONEBIT_SUITE
  exec "$ROOT/scripts/sync-bitnet-from-onebit-suite.sh"
fi

# --- Build from upstream BitNet ---
# Prereqs: cmake, clang, Python 3.9+, huggingface-cli; see BitNet README.
OUT="$ROOT/src-tauri/resources/bitnet-backend"
BITNET_SRC="${BITNET_SRC:-$HOME/src/BitNet}"
MODEL_DIR="${MODEL_DIR:-$BITNET_SRC/models/BitNet-b1.58-2B-4T-gguf}"
VERSION_FILE="${VERSION:-bitnet-cpp-1.0}"
BACKEND_FILE="${BACKEND:-bitnet-b1.58-2B-cpu}"

die() { echo "build-bitnet-backend: $*" >&2; exit 1; }

[[ -d "$BITNET_SRC" ]] || die "Set BITNET_SRC to your BitNet clone (git clone --recursive https://github.com/microsoft/BitNet.git)"

[[ -d "$MODEL_DIR" ]] || die "Download the GGUF model first, e.g. huggingface-cli download microsoft/BitNet-b1.58-2B-4T-gguf --local-dir $MODEL_DIR"

echo "Using BitNet at: $BITNET_SRC"
echo "Model dir: $MODEL_DIR"

(
  cd "$BITNET_SRC"
  python3 setup_env.py -md "$MODEL_DIR" -q i2_s
)

BIN="$BITNET_SRC/build/bin/llama-server"
[[ -x "$BIN" ]] || die "Expected executable not found: $BIN (did setup_env.py build succeed?)"

mkdir -p "$OUT/build/bin"
cp -f "$BIN" "$OUT/build/bin/"
# Optional: copy other binaries from build/bin if present (e.g. tools)
if [[ "$(uname -s)" == "Darwin" ]]; then
  for f in "$BITNET_SRC/build/bin"/*; do
    [[ -f "$f" && -x "$f" ]] || continue
    base="$(basename "$f")"
    [[ "$base" == "llama-server" ]] && continue
    cp -f "$f" "$OUT/build/bin/" 2>/dev/null || true
  done
fi

printf '%s' "$VERSION_FILE" > "$OUT/version.txt"
printf '%s' "$BACKEND_FILE" > "$OUT/backend.txt"

echo "Wrote bundled BitNet backend to $OUT"
echo "version.txt=$(cat "$OUT/version.txt") backend.txt=$(cat "$OUT/backend.txt")"
