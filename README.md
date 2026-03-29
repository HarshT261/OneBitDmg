<img src="https://github.com/AnirudhMalik/onebit/raw/main/assets/logo.png" width="80" alt="onebit" />

# onebit

Open-source ChatGPT alternative. Run local LLMs or connect cloud models — with full control and privacy.

<a href="https://github.com/AnirudhMalik/onebit/stargazers"><img src="https://img.shields.io/github/stars/AnirudhMalik/onebit?style=flat&logo=github&label=Stars&color=f5c542" alt="Stars" /></a>&nbsp;
<a href="https://github.com/AnirudhMalik/onebit/network/members"><img src="https://img.shields.io/github/forks/AnirudhMalik/onebit?style=flat&logo=github&label=Forks&color=4ac1f2" alt="Forks" /></a>&nbsp;
<a href="https://github.com/AnirudhMalik/onebit/commits/main"><img src="https://img.shields.io/github/last-commit/AnirudhMalik/onebit?style=flat&label=Last%20Commit&color=blueviolet" alt="Last Commit" /></a>&nbsp;
<img src="https://img.shields.io/badge/Built_with-Tauri-FFC131?style=flat&logo=tauri&logoColor=white" alt="Tauri" />&nbsp;
<img src="https://img.shields.io/badge/Runtime-Node.js_≥20-339933?style=flat&logo=nodedotjs&logoColor=white" alt="Node.js" />

[Bug Reports](https://github.com/AnirudhMalik/onebit/issues)

<p align="center">
  <img src="https://github.com/AnirudhMalik/onebit/raw/main/assets/preview.png" width="100%" alt="onebit interface" />
</p>

---

### Download

|                       |                                                                          |
| --------------------- | ------------------------------------------------------------------------ |
| **macOS (Universal)** | [Releases](https://github.com/AnirudhMalik/onebit/releases) |

Download from [GitHub Releases](https://github.com/AnirudhMalik/onebit/releases).

---

### Features

- 🧠 **Local AI Models** — download and run LLMs (Llama, Gemma, Qwen, and more) from HuggingFace
- ☁️ **Cloud Integration** — connect to OpenAI, Anthropic, Mistral, Groq, MiniMax, and others
- 🤖 **Custom Assistants** — create specialized AI assistants for your tasks
- 🔌 **OpenAI-Compatible API** — local server at `localhost:1337` for other applications
- 🔗 **Model Context Protocol** — MCP integration for agentic capabilities
- 🔒 **Privacy First** — everything runs locally when you want it to

---

### Build from Source

#### Prerequisites

- Node.js ≥ 20.0.0
- Yarn ≥ 4.5.3 (via Corepack; see **Yarn** under BitNet section if `yarn` is missing)
- Make ≥ 3.81
- **Rust** — `cargo` on your `PATH`. Easiest on macOS with Homebrew: `brew install rust rustup`, then `export PATH="/opt/homebrew/opt/rustup/bin:$PATH"`, `rustup default stable`, and `rustup target add aarch64-apple-darwin x86_64-apple-darwin` (needed for the universal `jan-cli` / Tauri build). Or install [rustup.rs](https://rustup.rs/) (adds `~/.cargo/bin`; creates `~/.cargo/env`).
- (Apple Silicon) MetalToolchain `xcodebuild -downloadComponent MetalToolchain`

#### Run with Make

```bash
git clone https://github.com/AnirudhMalik/onebit
cd onebit
make dev
```

This handles everything: installs dependencies, builds core components, and launches the app.

**Available make targets:**

- `make dev` — full development setup and launch
- `make build` — production build
- `make test` — run tests and linting
- `make clean` — delete everything and start fresh

#### Manual Commands

```bash
yarn install
yarn build:tauri:plugin:api
yarn build:core
yarn build:extensions
yarn dev
```

---

### BitNet b1.58 (bitnet.cpp) and standalone macOS builds

This fork bundles **two** local inference backends inside the app:

| Bundle | Purpose |
|--------|---------|
| **llamacpp-backend** | Stock **llama.cpp** `llama-server` (GGUF models from Hugging Face). Downloaded at build time via `make download-llamacpp-backend` (not committed; large). |
| **bitnet-backend** | **Microsoft BitNet / bitnet.cpp** `llama-server` for **1.58-bit BitNet GGUF** (e.g. `ggml-model-i2_s.gguf`). The normal backend cannot load these files. **Vendored in the repo** under `src-tauri/resources/bitnet-backend/` so installs work on any Mac without another project on disk. |

**Runtime behavior**

- On startup, the Llama.cpp extension installs both bundles from `Contents/Resources` into the app data folder (when present).
- In **Settings → Llama.cpp → Version & backend**, pick the BitNet line (e.g. `onebit-suite-bitnet/mac-arm64-bitnet`) before using a BitNet model; use the default/turboquant line for ordinary GGUF models.

**Rust / JS changes (high level)**

- `tauri-plugin-llamacpp`: `install_bundled_backend(backendsDir, bundle?)` with `bundle: 'bitnet'` reading `resources/bitnet-backend/` (same layout as `llamacpp-backend`: `version.txt`, `backend.txt`, `build/bin/llama-server`).
- `extensions/llamacpp-extension`: after the stock bundle, calls `installBundledBackend(backendsDir, 'bitnet')`.
- `tauri.conf.json` / `tauri.macos.conf.json`: `resources/bitnet-backend/` included in the bundle.
- `scripts/sign-macos-resource-binaries.sh`: signs Mach-O binaries under `resources/bitnet-backend/build/bin/` for notarization.
- `.github/workflows/release-macos.yml`: **Verify standalone bundles** step runs `scripts/verify-standalone-bundles.sh` so CI fails if BitNet is missing from the tree.

**One-time: populate BitNet into the repo**

From a local [OneBitAI Suite](https://github.com/anirudhmlik/onebit-1.58)-style tree that already has `bin/mac/llama-server-bitnet` and BitNet dylibs:

```bash
./scripts/sync-bitnet-from-onebit-suite.sh "/path/to/OneBitAI_Suite"
git add src-tauri/resources/bitnet-backend
git commit -m "Bundle BitNet backend for standalone DMG"
```

Or build from upstream [microsoft/BitNet](https://github.com/microsoft/BitNet) and copy `build/bin/llama-server` — see `src-tauri/resources/bitnet-backend/BUILD.txt`.

**Scripts**

| Script | Role |
|--------|------|
| `scripts/sync-bitnet-from-onebit-suite.sh` | Copies `llama-server-bitnet` → `build/bin/llama-server` + dylibs into `bitnet-backend/`. Requires `ONEBIT_SUITE` env or path as first argument. |
| `scripts/build-bitnet-backend.sh` | If `ONEBIT_SUITE` is set, runs the sync script; otherwise builds from a `BitNet` source clone. |
| `scripts/verify-standalone-bundles.sh` | Ensures llamacpp + bitnet bundles exist before packaging (macOS). |
| `scripts/build-macos-standalone-dmg.sh` | Full pipeline: download llamacpp if needed, verify bundles, then **`build:tauri:plugin:api` → `build:core` → `build:extensions:darwin`** (same order as `make install-and-build`), then web + icons + native bins, `tauri build` universal macOS. |

**Yarn**

Use Corepack (Yarn 4 is pinned in `package.json`). Put Homebrew first on `PATH` so Corepack is not the old one under `/usr/local` (which can error with `EACCES` on symlinks).

If `yarn` is missing or Corepack is broken, run Yarn via the helper (installs `corepack` through Homebrew’s `npm` once if needed):

```bash
chmod +x scripts/yarn-here.sh
./scripts/yarn-here.sh install
./scripts/yarn-here.sh build:macos:standalone
```

Or after `export PATH="/opt/homebrew/bin:$PATH"` and `npm install -g corepack` (Homebrew npm), use `corepack prepare yarn@4.5.3 --activate` and then `yarn` as usual.

```bash
yarn verify:standalone-bundles
yarn build:macos:standalone
```

**Git**

- `src-tauri/resources/**` is ignored except **`src-tauri/resources/bitnet-backend/**`**, so BitNet binaries can be committed for reproducible DMGs and CI.

**Branding / product**

- App name **onebit**, team **Anirudh Malik**, pixel logo under `web-app/public/images/` and Tauri icons; upstream “Jan” naming removed in many UI paths (see recent commits).

---

### System Requirements

- **macOS**: 13.6+ (8GB RAM for 3B models, 16GB for 7B, 32GB for 13B)

---

### Troubleshooting

**`yarn`: command not found / Corepack `EACCES` / wrong `corepack` path**

- Use **`./scripts/yarn-here.sh`** (see above), or ensure `which node` and `which corepack` are under `/opt/homebrew/bin`, not `/usr/local`.
- Do not paste commented lines from docs into zsh as-is; lines in parentheses can trigger `zsh: no matches found`.
- Homebrew Node 25 may not ship `corepack.js` at `$(brew --prefix node)/lib/node_modules/corepack/...`; install the CLI with: `/opt/homebrew/bin/npm install -g corepack`.

If something else isn’t working:

1. Copy your error logs and system specs
2. Open an issue on [GitHub](https://github.com/AnirudhMalik/onebit/issues)

---

### Contributing

Contributions welcome. See [CONTRIBUTING.md](CONTRIBUTING.md) for details.

<p align="center">
  <a href="https://github.com/AnirudhMalik/onebit/issues"><img src="https://img.shields.io/badge/🐛_Report-Issues-FF4444?style=for-the-badge" alt="Report Issues" /></a>&nbsp;
  <a href="https://github.com/AnirudhMalik/onebit/pulls"><img src="https://img.shields.io/badge/🔀_Submit-PRs-44CC11?style=for-the-badge" alt="Submit PRs" /></a>
</p>

---

### Contact

- **Bugs**: [GitHub Issues](https://github.com/AnirudhMalik/onebit/issues)

---

### License

Apache 2.0 — see [LICENSE](LICENSE) for details.

### Acknowledgements

Built on the shoulders of giants:

- [Llama.cpp](https://github.com/ggerganov/llama.cpp)
- [Microsoft BitNet / bitnet.cpp](https://github.com/microsoft/BitNet) (optional bundled backend)
- [Tauri](https://tauri.app/)
- [Scalar](https://github.com/scalar/scalar)

---

<p align="center">
  <sub>© 2026 onebit · Team: Anirudh Malik</sub>
</p>
