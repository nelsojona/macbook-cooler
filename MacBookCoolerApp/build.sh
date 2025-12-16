#!/bin/bash
# MacBook Cooler App Build Script
# Builds the macOS menu bar application

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$SCRIPT_DIR"
BUILD_DIR="$PROJECT_DIR/build"
APP_NAME="MacBook Cooler"

echo "🔨 Building MacBook Cooler..."

# Clean previous build
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

# Build the app
xcodebuild -project "$PROJECT_DIR/MacBookCooler.xcodeproj" \
    -scheme MacBookCooler \
    -configuration Release \
    -derivedDataPath "$BUILD_DIR/DerivedData" \
    -archivePath "$BUILD_DIR/MacBookCooler.xcarchive" \
    archive \
    CODE_SIGN_IDENTITY="-" \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGNING_ALLOWED=NO

# Export the app
xcodebuild -exportArchive \
    -archivePath "$BUILD_DIR/MacBookCooler.xcarchive" \
    -exportPath "$BUILD_DIR/Export" \
    -exportOptionsPlist "$PROJECT_DIR/ExportOptions.plist"

# Create DMG
echo "📦 Creating DMG..."
DMG_PATH="$BUILD_DIR/MacBookCooler.dmg"
APP_PATH="$BUILD_DIR/Export/MacBookCooler.app"

# Create temporary DMG directory
DMG_TEMP="$BUILD_DIR/dmg_temp"
mkdir -p "$DMG_TEMP"
cp -R "$APP_PATH" "$DMG_TEMP/"
ln -s /Applications "$DMG_TEMP/Applications"

# Create DMG
hdiutil create -volname "MacBook Cooler" \
    -srcfolder "$DMG_TEMP" \
    -ov -format UDZO \
    "$DMG_PATH"

# Cleanup
rm -rf "$DMG_TEMP"

echo "✅ Build complete!"
echo "📍 DMG: $DMG_PATH"
echo "📍 App: $APP_PATH"
