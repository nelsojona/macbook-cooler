#!/bin/bash
# MacBook Cooler App Build Script
# Builds the macOS menu bar application and creates DMG installer

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$SCRIPT_DIR"
BUILD_DIR="$PROJECT_DIR/build"
APP_NAME="MacBook Cooler"
VERSION="1.0.0"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo ""
echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║         MacBook Cooler Build Script v${VERSION}               ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

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
DMG_PATH="$BUILD_DIR/MacBookCooler-${VERSION}.dmg"
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

# Calculate SHA256
SHA256=$(shasum -a 256 "$DMG_PATH" | awk '{print $1}')
echo "$SHA256" > "$BUILD_DIR/MacBookCooler-${VERSION}.dmg.sha256"

echo ""
echo -e "${GREEN}════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}  ✅ Build Complete!${NC}"
echo -e "${GREEN}════════════════════════════════════════════════════════════${NC}"
echo ""
echo "  📍 App: $APP_PATH"
echo "  📍 DMG: $DMG_PATH"
echo "  🔐 SHA256: $SHA256"
echo ""
echo "  To create a GitHub release:"
echo "    gh release create v${VERSION} \"$DMG_PATH\" \\"
echo "      --title \"MacBook Cooler v${VERSION}\" \\"
echo "      --notes-file CHANGELOG.md"
echo ""
