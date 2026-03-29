#!/usr/bin/env bash
# Run Yarn 4 for this repo when `yarn` is not on PATH (Corepack / multiple Node installs).
# Prefers Homebrew so we do not hit /usr/local permission errors.
#
# Usage: ./scripts/yarn-here.sh install
#        ./scripts/yarn-here.sh build:macos:standalone
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:/usr/bin:/bin:${PATH:-}"
hash -r

run_yarn() {
  if command -v yarn >/dev/null 2>&1; then
    exec yarn "$@"
  fi
  local cp
  cp="$(command -v corepack 2>/dev/null || true)"
  if [[ -z "$cp" || "$cp" == /usr/local/* ]]; then
    if [[ -x /opt/homebrew/bin/npm ]]; then
      echo "Installing corepack via Homebrew npm (one-time)..." >&2
      /opt/homebrew/bin/npm install -g corepack
      hash -r
    fi
    cp="$(command -v corepack 2>/dev/null || true)"
  fi
  if [[ -z "$cp" ]]; then
    echo "No corepack found. Install: /opt/homebrew/bin/npm install -g corepack" >&2
    exit 1
  fi
  "$cp" prepare yarn@4.5.3 --activate
  exec "$cp" yarn "$@"
}

run_yarn "$@"
