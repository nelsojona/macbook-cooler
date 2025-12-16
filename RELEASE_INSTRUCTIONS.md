# MacBook Cooler v1.1.0 Release Instructions

This document provides step-by-step instructions for building and releasing MacBook Cooler v1.1.0.

## Prerequisites

Before proceeding, ensure you have the following installed on your Mac:

- Xcode 15.0 or later (with Command Line Tools)
- Homebrew
- GitHub CLI (`gh`)

## Step 1: Build the DMG

On your Mac, navigate to the MacBookCoolerApp directory and run the build script:

```bash
cd ~/path/to/macbook-cooler/MacBookCoolerApp
chmod +x build.sh
./build.sh
```

The build script will:
1. Build the MacBook Cooler app using Xcode
2. Create a DMG installer at `build/MacBookCooler-v1.1.0.dmg`
3. Calculate and display the SHA256 hash

**Expected output:**
```
📍 App: build/Export/MacBookCooler.app
📍 DMG: build/MacBookCooler-v1.1.0.dmg
🔐 SHA256: <sha256-hash>
```

## Step 2: Create GitHub Release

After building the DMG, create a GitHub release with the following command:

```bash
cd ~/path/to/macbook-cooler

# Create the release and upload the DMG
gh release create v1.1.0 \
  "MacBookCoolerApp/build/MacBookCooler-v1.1.0.dmg" \
  --title "MacBook Cooler v1.1.0" \
  --notes "## What's New in v1.1.0

### Native macOS Menu Bar Application
- Beautiful glassmorphism UI matching macOS Sonoma aesthetics
- Real-time CPU and GPU temperature monitoring
- Temperature display in Fahrenheit (default) or Celsius
- Light, Dark, and System appearance modes
- Quick power mode switching (Low Power, Automatic, High Performance)
- Sliding settings panel with smooth spring animations
- Configurable temperature thresholds
- Launch at Login functionality
- Template-mode menu bar icon that adapts to system appearance

### Installation Options
- **DMG Installer**: Download and drag to Applications
- **Homebrew Cask**: \`brew install --cask macbook-cooler-app\`
- **CLI Tools**: \`brew install macbook-cooler\`

### Full Changelog
See [CHANGELOG.md](https://github.com/nelsojona/macbook-cooler/blob/main/CHANGELOG.md)"
```

## Step 3: Update Homebrew Formulas with SHA256

After creating the release, you need to update the SHA256 hashes in the Homebrew formulas.

### Get the SHA256 for the source tarball:

```bash
# Download and calculate SHA256 for the source tarball
curl -sL https://github.com/nelsojona/macbook-cooler/archive/refs/tags/v1.1.0.tar.gz | shasum -a 256
```

### Get the SHA256 for the DMG:

The DMG SHA256 was displayed when you ran the build script. You can also calculate it:

```bash
shasum -a 256 MacBookCoolerApp/build/MacBookCooler-v1.1.0.dmg
```

### Update the homebrew-macbook-cooler tap:

```bash
cd ~/path/to/homebrew-macbook-cooler

# Edit Formula/macbook-cooler.rb
# Replace: sha256 :no_check  # Update with actual SHA256 after release
# With:    sha256 "<source-tarball-sha256>"

# Edit Casks/macbook-cooler-app.rb
# Replace: sha256 :no_check
# With:    sha256 "<dmg-sha256>"

# Commit and push
git add -A
git commit -m "Update SHA256 hashes for v1.1.0 release"
git push origin main
```

## Step 4: Verify Installation

Test both installation methods to ensure everything works:

### Test Homebrew Cask:

```bash
brew tap nelsojona/macbook-cooler
brew install --cask macbook-cooler-app
```

### Test DMG Download:

1. Download the DMG from the GitHub release page
2. Open the DMG and drag MacBook Cooler to Applications
3. Launch the app from Applications

## File Checklist

Ensure all version numbers are consistent across these files:

| File | Location | Version |
|------|----------|---------|
| `build.sh` | MacBookCoolerApp/build.sh | VERSION="1.1.0" |
| `project.pbxproj` | MacBookCoolerApp/MacBookCooler.xcodeproj/ | MARKETING_VERSION = 1.1.0 |
| `MenuBarView.swift` | MacBookCoolerApp/MacBookCooler/Sources/ | Text("1.1.0") |
| `CHANGELOG.md` | Root directory | ## [1.1.0] |
| `README.md` | Root directory | Version-1.1.0 badge |
| `macbook-cooler.rb` | Formula/ | v1.1.0.tar.gz |
| `macbook-cooler.rb` | homebrew-macbook-cooler/Formula/ | v1.1.0.tar.gz |
| `macbook-cooler-app.rb` | homebrew-macbook-cooler/Casks/ | version "1.1.0" |

## Troubleshooting

### Build fails with code signing error

The build script is configured to build without code signing. If you encounter issues, ensure these settings in the build command:

```bash
CODE_SIGN_IDENTITY="-"
CODE_SIGNING_REQUIRED=NO
CODE_SIGNING_ALLOWED=NO
```

### App won't open on first launch

Since the app is not notarized, users may need to:
1. Right-click the app in Finder
2. Select "Open"
3. Click "Open" in the dialog

### Homebrew formula fails to install

If the SHA256 doesn't match, re-download the tarball and recalculate:

```bash
curl -sL https://github.com/nelsojona/macbook-cooler/archive/refs/tags/v1.1.0.tar.gz | shasum -a 256
```

## Summary of Commands

```bash
# 1. Build DMG (on Mac)
cd MacBookCoolerApp && ./build.sh

# 2. Create GitHub release
gh release create v1.1.0 "MacBookCoolerApp/build/MacBookCooler-v1.1.0.dmg" \
  --title "MacBook Cooler v1.1.0" \
  --notes-file CHANGELOG.md

# 3. Get SHA256 for source tarball
curl -sL https://github.com/nelsojona/macbook-cooler/archive/refs/tags/v1.1.0.tar.gz | shasum -a 256

# 4. Update homebrew-macbook-cooler formulas with SHA256 hashes
# 5. Test installation
brew tap nelsojona/macbook-cooler && brew install --cask macbook-cooler-app
```
