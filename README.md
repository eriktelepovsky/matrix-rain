# Matrix Rain Screensaver

A Matrix-style falling character rain screensaver for macOS, built in native Swift with no dependencies.

![macOS](https://img.shields.io/badge/macOS-13.0%2B-blue)

## Features

- Katakana and numeric characters falling in columns
- Distinct head (bright) and trail (fading) colors
- Fully configurable via System Settings Options panel
- Settings persist across launches

## Requirements

- macOS 13.0 or later
- Xcode Command Line Tools (`xcode-select --install`)

## Build & Install

```sh
make install
```

This compiles the screensaver, copies it to `~/Library/Screen Savers/`, and restarts the screensaver process to load the new version.

```sh
make uninstall   # remove from ~/Library/Screen Savers/
make clean       # delete the local build artifact
```

## Configuration

Open **System Settings → Screen Saver**, select **Matrix Rain**, then click **Options**.

| Option | Description |
|---|---|
| Character Size | Font size and column width (8–24 px) |
| Rain Speed | How fast characters fall |
| Trail Length | How long the fading trail is |
| Trail Color | Color of the fading trail |
| Head Color | Color of the leading character |
| Glyphs | Character set used for the rain |

Changes apply immediately to the running screensaver without restarting it.

## Project Structure

```
MatrixScreenSaver.swift   — all screensaver logic and config sheet
Info.plist                — bundle metadata (identifier, principal class)
Makefile                  — build, install, uninstall, clean targets
```

## How It Works

The screensaver subclasses `ScreenSaverView` and renders into an `NSBitmapImageRep` accumulation buffer each frame. Each column tracks its own drop position and speed. A semi-transparent black overlay is blended over the buffer every frame to fade old characters toward black, creating the trail effect. Settings are stored via `ScreenSaverDefaults` and propagated to the running process using Darwin notifications (`CFNotificationCenter`).
