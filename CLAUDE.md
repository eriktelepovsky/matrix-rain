# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Matrix Rain is a Matrix-style falling character animation available in two forms:
- **JavaScript canvas library** (`javascript/matrix-rain.js`) — zero-dependency, drop-in for web pages
- **Native macOS screensaver** (`screensaver/MatrixScreenSaver.swift`) — built on the same algorithm, configurable via System Settings

## Screensaver Build Commands

All commands run from the `screensaver/` directory:

```sh
cd screensaver
make install     # build + install to ~/Library/Screen Savers/
make package     # build + create MatrixSaver.zip for distribution
make uninstall   # remove from ~/Library/Screen Savers/
make clean       # delete local build artifacts
```

Requires macOS 13.0+ and Xcode Command Line Tools (`xcode-select --install`). Built with `swiftc` directly — no Xcode project file.

## Architecture

### Shared Algorithm

Both implementations share the same core logic:

1. Each column tracks: `drops` (current row position as float), `speeds` (random fall rate), `prevHeads` (last frame's head row), `grid` (frozen character per cell).
2. Each frame: fill background with semi-transparent black to fade old characters (trail effect), then draw trail characters in `trailColor` and the leading character in `headColor`.
3. When a drop reaches the bottom, it resets with a configurable probability.

### JS Library (`javascript/matrix-rain.js`)

- Single function `MatrixRain(config)` — no classes, no modules, no dependencies.
- Uses `requestAnimationFrame` with a `frameDelay` guard.
- `canvas#matrix-rain` must exist in the DOM before calling.
- Re-initializes on horizontal resize only.

### Swift Screensaver (`screensaver/MatrixScreenSaver.swift`)

- Subclasses `ScreenSaverView`; `animateOneFrame()` drives the loop at 20 fps.
- Uses `NSBitmapImageRep` as an accumulation buffer (equivalent to the JS canvas fade trick).
- **Settings persistence**: `ScreenSaverDefaults` keyed under `sk.telepovsky.MatrixSaver`.
- **Live reload**: settings changes post a Darwin notification (`CFNotificationCenter`) so the running screensaver picks them up instantly without restart.
- The config sheet is built programmatically (no XIB/storyboard).

### Preview Files (`previews/`)

Standalone HTML files that demonstrate themes by calling `MatrixRain()` with different parameters. They reference `../javascript/matrix-rain.js` via relative path — open directly in a browser.

## Key Parameters

**JS:** `fontSize`, `fadeSpeed` (0–1, lower = longer trail), `frameDelay` (ms), `speedMin/Max`, `resetChance` (0–1), `bgColor`, `trailColor`, `headColor`, `chars`.

**Swift:** `colSize` (px), `speed` (average; min = speed×0.4, max = speed×1.6), `trailLen` (1–15; maps to `fadeAlpha = 0.16 - trailLen×0.01`), `trailColor`, `headColor`, `glyphs`.
