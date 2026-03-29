#!/usr/bin/env python3
# Canonical app icon: docs/public/assets/images/onebit-logo.png → web-app images, Dock / install / tray, then `tauri icon`.
from __future__ import annotations

import shutil
import sys
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parent.parent
CANONICAL_LOGO = (
    ROOT / "docs" / "public" / "assets" / "images" / "onebit-logo.png"
)
LEGACY_LOGO = ROOT / "assets" / "logo.png"
LOGO_APP_PATH = ROOT / "web-app" / "public" / "images" / "logo-app.png"
TRANSPARENT_LOGO_PATH = ROOT / "web-app" / "public" / "images" / "transparent-logo.png"
PUBLIC_LOGO_PATH = ROOT / "web-app" / "public" / "images" / "logo.png"
TRAY_PATH = ROOT / "web-app" / "public" / "images" / "tray-macos-template.png"
OUT_PATH = ROOT / "src-tauri" / "icons" / "icon.png"
APP_ICON_ROOT = ROOT / "src-tauri" / "app-icon.png"
SIZE = 1024
# Fraction of canvas used by artwork (rest is transparent inset, typical macOS Dock grid)
DOCK_ART_FRAC = 0.82
TRAY_PX = 22


def sync_canonical_to_public_images() -> Path:
    """Use docs/.../onebit-logo.png (fallback: assets/logo.png) for in-app, favicon, and DMG metadata."""
    if CANONICAL_LOGO.is_file():
        src = CANONICAL_LOGO
    elif LEGACY_LOGO.is_file():
        src = LEGACY_LOGO
    elif LOGO_APP_PATH.is_file():
        src = LOGO_APP_PATH
    else:
        print(
            f"Missing {CANONICAL_LOGO} (or {LEGACY_LOGO} or {LOGO_APP_PATH})",
            file=sys.stderr,
        )
        sys.exit(1)
    im = Image.open(src).convert("RGBA")
    LOGO_APP_PATH.parent.mkdir(parents=True, exist_ok=True)
    LEGACY_LOGO.parent.mkdir(parents=True, exist_ok=True)
    im.save(LOGO_APP_PATH, "PNG")
    im.save(TRANSPARENT_LOGO_PATH, "PNG")
    im.save(PUBLIC_LOGO_PATH, "PNG")
    im.save(LEGACY_LOGO, "PNG")
    print(
        f"Synced OneBit logo from {src} → logo-app, transparent-logo, images/logo.png, assets/logo.png"
    )
    return LOGO_APP_PATH


def write_tray_template_from_logo(logo_path: Path) -> None:
    """Black glyph + alpha for NSStatusItem template (menu bar)."""
    im = Image.open(logo_path).convert("RGBA")
    im = im.resize((TRAY_PX, TRAY_PX), Image.Resampling.LANCZOS)
    _, _, _, alpha = im.split()
    black = Image.new("RGB", (TRAY_PX, TRAY_PX), (0, 0, 0))
    out = Image.merge("RGBA", (*black.split(), alpha))
    out.save(TRAY_PATH, "PNG")
    print(f"Wrote {TRAY_PATH} ({TRAY_PX}×{TRAY_PX} template)")


def main() -> None:
    logo_path = sync_canonical_to_public_images()
    write_tray_template_from_logo(logo_path)

    im = Image.open(logo_path).convert("RGBA")
    side = max(1, int(round(SIZE * DOCK_ART_FRAC)))
    im = im.resize((side, side), Image.Resampling.LANCZOS)

    canvas = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    ox = (SIZE - side) // 2
    oy = (SIZE - side) // 2
    canvas.alpha_composite(im, (ox, oy))

    OUT_PATH.parent.mkdir(parents=True, exist_ok=True)
    canvas.save(OUT_PATH, "PNG")
    print(
        f"Wrote {OUT_PATH} from {logo_path} ({SIZE}×{SIZE}, art {side}px, frac={DOCK_ART_FRAC})"
    )
    shutil.copyfile(OUT_PATH, APP_ICON_ROOT)
    print(f"Copied → {APP_ICON_ROOT} (install / bundle reference)")


if __name__ == "__main__":
    main()
