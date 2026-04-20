#!/bin/bash

APP_NAME="QuickGif"
BUNDLE_ID="com.cyber.QuickGif"
BUILD_DIR=".build/release"
APP_DIR="${APP_NAME}.app"
DMG_NAME="${APP_NAME}_Installer.dmg"
TEMP_DMG_DIR="temp_dmg_folder"

echo "🚀 Starting build process for ${APP_NAME}..."

# 1. Build Swift project
echo "📦 Compiling Swift project in release mode..."
swift build -c release

if [ $? -ne 0 ]; then
    echo "❌ Build failed!"
    exit 1
fi

# 2. Create App Bundle structure
echo "📂 Creating .app structure..."
rm -rf "${APP_DIR}"
mkdir -p "${APP_DIR}/Contents/MacOS"

# 3. Copy binary
cp "${BUILD_DIR}/${APP_NAME}" "${APP_DIR}/Contents/MacOS/"

# 4. Create Info.plist
cat <<PLIST > "${APP_DIR}/Contents/Info.plist"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>${APP_NAME}</string>
    <key>CFBundleIdentifier</key>
    <string>${BUNDLE_ID}</string>
    <key>CFBundleName</key>
    <string>${APP_NAME}</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>LSMinimumSystemVersion</key>
    <string>14.0</string>
    <key>NSHighResolutionCapable</key>
    <true/>
</dict>
</plist>
PLIST

# 5. Set permissions
chmod +x "${APP_DIR}/Contents/MacOS/${APP_NAME}"

# 6. Create DMG
echo "💿 Creating DMG installer..."
rm -rf "${TEMP_DMG_DIR}"
rm -f "${DMG_NAME}"
mkdir -p "${TEMP_DMG_DIR}"
cp -R "${APP_DIR}" "${TEMP_DMG_DIR}/"
ln -s /Applications "${TEMP_DMG_DIR}/Applications"

hdiutil create -volname "${APP_NAME} Installer" -srcfolder "${TEMP_DMG_DIR}" -ov -format UDZO "${DMG_NAME}"

# 7. Cleanup
rm -rf "${TEMP_DMG_DIR}"
echo "✅ Done! ${DMG_NAME} created on your desktop."
EOF

chmod +x build_dmg.sh