# Contributing to OneBit AI

OneBit AI is maintained by **Anirudh Malik** and **Harsh Tyagi**. This document describes how the repository is organized and how to build and test changes.

## Quick Links to Component Guides

- **[Web App](./web-app/CONTRIBUTING.md)** — React UI and logic
- **[Core SDK](./core/CONTRIBUTING.md)** — TypeScript SDK and extension system
- **[Extensions](./extensions/CONTRIBUTING.md)** — Supportive modules for the frontend
- **[Tauri Backend](./src-tauri/CONTRIBUTING.md)** — Rust native integration
- **[Tauri Plugins](./src-tauri/plugins/CONTRIBUTING.md)** — Hardware and system plugins

## Project Structure

```
OneBit AI/
├── web-app/              # React frontend
├── src-tauri/            # Rust backend
├── core/                 # TypeScript SDK
├── extensions/           # JavaScript extensions
├── docs/                 # Documentation site
├── scripts/              # Build utilities
├── package.json
├── Makefile
├── LICENSE
└── README.md
```

## Development Setup

**Prerequisites:** Node.js ≥ 20, Yarn ≥ 4.5.3 (Corepack), Make ≥ 3.81, Rust (for Tauri), and on Apple Silicon the Metal toolchain where applicable.

```bash
git clone https://github.com/anirudhmlik/onebit
cd onebit
make dev
```

## Reporting Issues

Search [existing issues](https://github.com/anirudhmlik/onebit/issues) first, then open a new one with steps to reproduce and environment details.

## License

Apache 2.0 — see [LICENSE](./LICENSE).
