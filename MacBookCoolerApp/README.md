# MacBook Cooler Menu Bar App

A native macOS menu bar application with a modern glassmorphism design for thermal management on Apple Silicon MacBooks.

## Features

- **Real-time Temperature Monitoring**: See CPU and GPU temperatures at a glance
- **Glassmorphism UI**: Modern, translucent design that follows Apple's Human Interface Guidelines
- **Homebrew Integration**: Smart onboarding that detects and installs CLI tools automatically
- **Easy Upgrades**: One-click upgrade when new versions are available
- **Service Control**: Start/stop the background thermal management service
- **Power Mode Control**: Switch between Automatic, Low Power, Normal, and High Performance modes
- **Dark/Light Mode Support**: Automatically adapts to your system appearance

## Requirements

- macOS 13.0 (Ventura) or later
- Apple Silicon Mac (M1, M2, M3, M4 series)
- Homebrew (for CLI tools integration)

## Installation

### Via Homebrew Cask (Recommended)

```bash
brew tap nelsojona/macbook-cooler
brew install --cask macbook-cooler-app
```

This will automatically install the CLI tools as a dependency.

### Manual Build

1. Open `MacBookCooler.xcodeproj` in Xcode
2. Select your development team in Signing & Capabilities
3. Build and run (⌘R)

Or use the build script:

```bash
./build.sh
```

## Onboarding Flow

When you first launch the app, it will:

1. **Check for Homebrew**: If not installed, provides a link to install it
2. **Check for CLI Tools**: If not installed, offers one-click installation
3. **Check for Updates**: If outdated, offers one-click upgrade
4. **Start Service**: Automatically starts the background thermal management service

## Architecture

```
MacBookCoolerApp/
├── MacBookCooler/
│   ├── Sources/
│   │   ├── MacBookCoolerApp.swift    # App entry point
│   │   ├── AppState.swift            # State management & Homebrew integration
│   │   └── MenuBarView.swift         # SwiftUI views with glassmorphism
│   ├── Resources/
│   │   └── Assets.xcassets           # App icons and colors
│   ├── Info.plist                    # App configuration
│   └── MacBookCooler.entitlements    # App permissions
├── MacBookCooler.xcodeproj           # Xcode project
├── build.sh                          # Build script
└── ExportOptions.plist               # Export configuration
```

## License

MIT License - see the main repository for details.
