---
name: recolor-pngs
description: Recolor PNG assets in Prusa-Firmware-Buddy-DEV/src from Prusa orange to SimplyPrint blue. Use when refreshing image assets after a version upgrade or when the developer asks to "recolor the icons / PNGs / assets".
---

# Recolor PNG assets

Runs `color_converter.py` at the repo root, which walks `Prusa-Firmware-Buddy-DEV/src/`, finds every `.png`, and rewrites pixels matching any of several Prusa-orange shades to SimplyPrint blue (`#38b6ff`). Tolerance is per-channel ±40.

## When to use

- After `./upgrade_version.sh` pulls in new upstream PNG assets that still use Prusa orange.
- When the developer asks to refresh image colors / icons / branding in the dev clone.

## How to run

```bash
python color_converter.py
```

Requires `Pillow` (already in the Pipfile environment). Edits files in place under `Prusa-Firmware-Buddy-DEV/src/`. After running, capture the recolored PNGs into patches with `./make_patches.sh <version>` — they will be auto-segregated into `patches/v<version>/png_patches/`.

## Tunables

If a new asset uses a Prusa-orange shade not yet covered, add another `process_images_in_folder(...)` call in [color_converter.py](../../../color_converter.py) with the RGB tuple of the new shade. The replacement color and tolerance are constant.
