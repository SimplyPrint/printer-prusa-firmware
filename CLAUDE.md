# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

This is **not** the Prusa firmware source — it is a **patch overlay** that customizes upstream [Prusa-Firmware-Buddy](https://github.com/prusa3d/Prusa-Firmware-Buddy) for SimplyPrint integration (SimplyPrint networking, screen lock, custom color scheme, message screen replacing the OctoPrint logo, etc. — see [README.md](README.md)).

The source of truth is the `patches/` directory. At build time, the upstream repo is cloned, a release tag is checked out, and patches are applied with `git apply`.

## Build & develop

```bash
# Build firmware locally — reuses ./Prusa-Firmware-Buddy if present, else clones it.
# Output: build/<preset>_release_boot/firmware.bbf
./local_build.sh <presets> <version> <WebSocket:ON|OFF>
# Example: ./local_build.sh mk4,xl,coreone v6.5.3 ON

# Generate patches from local edits in Prusa-Firmware-Buddy-DEV/
# and merge them into patches/v<version>/ via `smartcopy`
./make_patches.sh <version>

# Re-clone Prusa-Firmware-Buddy-DEV/ at <target_version> and apply patches/v<patch_version>/.
# Reports failed/conflicted patches but does not stop on failure.
./upgrade_version.sh <target_version> <patch_version>
```

There is no test suite — verification is "does it build" + manual print testing on a physical printer by the developer.

Builds require Python 3.12 + pipenv. `BUDDY_NO_VIRTUALENV=1` is exported so Prusa's `utils/build.py` doesn't try to manage its own venv. Valid presets: `mk4, xl, mini, mk3.5, coreone, coreonel`.

## Workflows

There are two end-to-end flows depending on the type of change. **Always confirm with the developer which flow applies** before starting.

### Flow A — Upgrading to a new upstream version

Use when bumping to a newer Prusa-Firmware-Buddy release tag.

1. Reset and re-apply existing patches against the new tag:
   ```bash
   ./upgrade_version.sh <NEW_VERSION> <PATCH_VERSION>
   ```
   `NEW_VERSION` is the upstream tag being upgraded to (e.g. `v6.5.3`). `PATCH_VERSION` is the latest stable patch set in `patches/` (e.g. `v6.5.2`).
2. Inspect rejected patches (`.rej` files in `Prusa-Firmware-Buddy-DEV/`), document each conflict, and hand-merge the fix into the working tree.
3. Build for `mk4` from inside the dev clone:
   ```bash
   cd Prusa-Firmware-Buddy-DEV
   pipenv run python utils/build.py --preset mk4 --signing-key "../firmware_signing_key.pem" --final --build-dir "../build" --bootloader yes -D WEBSOCKET:BOOL=ON
   ```
4. **Hand the resulting `.bbf` to the developer to flash and test on a physical printer.** Do not proceed until they confirm it works.
5. Capture the merged changes into the new version's patch set:
   ```bash
   ./make_patches.sh <NEW_VERSION>
   ```
6. Commit the new `patches/v<NEW_VERSION>/` directory with a message documenting which patches required rework and why, then open a PR.

### Flow B — Bug fix or new feature on the current version

Use when changing behavior without bumping the upstream version.

1. Reset `Prusa-Firmware-Buddy-DEV/` to a clean patched state with `./upgrade_version.sh` (same target and patch version — current version on both sides).
2. Implement the change in `Prusa-Firmware-Buddy-DEV/`.
3. Build (same command as Flow A step 3) and ask the developer to test on a physical printer.
4. Once confirmed working, run `./make_patches.sh <version>` to capture the diff into `patches/v<version>/`.
5. Commit with a detailed message describing the bug/feature and the approach, then open a PR.

## Architecture

### The two upstream clones

- **`Prusa-Firmware-Buddy/`** — build target. Both `scripts/build.sh` and `scripts/build_local.sh` do `git reset --hard HEAD && git checkout tags/<version>` then apply patches before invoking `utils/build.py`. **Anything you change here will be wiped on next build.** Gitignored.
- **`Prusa-Firmware-Buddy-DEV/`** — development workspace. Edit code here, then run `make_patches.sh` to capture your changes as patches. Gitignored.

### Patch layout

- `patches/v<version>/*.patch` — applied only when building that version (e.g. `patches/v6.2.6/`, `patches/v6.5.3/`).
- `patches/v<version>/png_patches/*.patch` — image assets, split into a subdir because [generate_patches.sh](generate_patches.sh) moves all `*.png.patch` files there.
- `new_patches/` — scratch output of `generate_patches.sh`, consumed by `make_patches.sh`. Gitignored.

**Never place patches at `patches/*.patch` (top level).** Every patch must live under a `patches/v<version>/` subdirectory so it is scoped to a specific upstream release.

Patch filenames use `_` as a path separator (e.g. `src_common_screen_lock.cpp.patch` = `src/common/screen_lock.cpp`).

### The patch-generation flow

`make_patches.sh <version>` runs in two stages:
1. `generate_patches.sh` — diffs `Prusa-Firmware-Buddy-DEV/` (both staged and unstaged) into `new_patches/`, one file per changed source file. Auto-segregates `*.png.patch` into `new_patches/png_patches/`.
2. `smartcopy` — merges `new_patches/*` into `patches/v<version>/`. `smartcopy` is an external tool fetched on demand from `gitlab.rylanswebsite.com`; the script self-installs it if missing.

### Build scripts

| Script | Purpose | Behavior |
|---|---|---|
| `local_build.sh` | Entry point | Picks fresh vs incremental |
| `scripts/build.sh` | Fresh build | `rm -rf` and re-clone upstream |
| `scripts/build_local.sh` | Incremental | Reuses existing clone, `git reset --hard` + `git clean -fd` |

All build paths shell out to `pipenv run python utils/build.py --preset <…> --build-type release --final --signing-key firmware_signing_key.pem --bootloader yes -D WEBSOCKET:BOOL=<…>`.

### CI

- **[.github/workflows/build_and_upload_firmware.yml](.github/workflows/build_and_upload_firmware.yml)** — `workflow_dispatch` only; picks the latest tag, runs `local_build.sh`, uploads `.bbf` files to the GitHub Release. The current branch `github_workflow` has active WIP refining this pipeline.

## Gotchas

- **Never commit `Prusa-Firmware-Buddy*/`, `firmware_signing_key.pem`, `*.pem`, `*.crt`, `*.key`, or `new_patches/`** — all gitignored or sensitive. The signing key is injected from CI secrets (`FIRMWARE_SIGNING_KEY`).
- **Don't edit `Prusa-Firmware-Buddy/` directly** — changes are wiped on every build. Use `Prusa-Firmware-Buddy-DEV/`.
- **Don't read or write [notes.txt](notes.txt)** — it is the developer's personal notes file, not project documentation.
- `scripts/build.sh` sets `git remote set-url --push origin DISABLED` on the upstream clone to prevent accidental pushes — preserve this when editing build scripts.
- `WebSocket:ON/OFF` is a positional 3rd argument to the build scripts and is wired through to CMake as `-D WEBSOCKET:BOOL=...`.
