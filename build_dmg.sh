#!/bin/bash

# --- 配置区 ---
APP_NAME="QuickGif"
BUNDLE_ID="com.cyber.QuickGif"
# --------------

VERSION_FILE="VERSION.txt"
BUILD_NUMBER_FILE="BUILD_NUMBER.txt"

# 1. 处理面向用户的版本号 (VERSION)
if [ ! -f "${VERSION_FILE}" ]; then
    echo "1.0.0" > "${VERSION_FILE}"
fi
VERSION=$(cat "${VERSION_FILE}")

# 2. 递增修订版本号 (e.g., 1.0.0 -> 1.0.1)
BASE_VERSION=$(echo $VERSION | cut -d. -f1,2)
PATCH_VERSION=$(echo $VERSION | cut -d. -f3)
NEW_PATCH=$((PATCH_VERSION + 1))
NEW_VERSION="${BASE_VERSION}.${NEW_PATCH}"
echo "${NEW_VERSION}" > "${VERSION_FILE}"

# 3. 处理内部构建号 (BUILD_NUMBER)
if [ ! -f "${BUILD_NUMBER_FILE}" ]; then
    echo "1" > "${BUILD_NUMBER_FILE}"
fi
BUILD_NUMBER=$(cat "${BUILD_NUMBER_FILE}")
NEXT_BUILD=$((BUILD_NUMBER + 1))
echo "${NEXT_BUILD}" > "${BUILD_NUMBER_FILE}"

BUILD_DIR=".build/release"
APP_DIR="${APP_NAME}.app"
DMG_NAME="${APP_NAME}_v${VERSION}_b${BUILD_NUMBER}.dmg"
TEMP_DMG_DIR="temp_dmg_folder"
ICON_NAME="AppIcon.icns"

echo "🚀 Starting build process for ${APP_NAME} v${VERSION} (Build ${BUILD_NUMBER})..."

# 4. 编译 Swift 项目
echo "📦 Compiling Swift project in release mode..."
swift build -c release

if [ $? -ne 0 ]; then
    echo "❌ Build failed!"
    exit 1
fi

# 5. 创建 App Bundle 结构
echo "📂 Creating .app structure..."
rm -rf "${APP_DIR}"
mkdir -p "${APP_DIR}/Contents/MacOS"
mkdir -p "${APP_DIR}/Contents/Resources"

# 6. 拷贝二进制文件和图标
cp "${BUILD_DIR}/${APP_NAME}" "${APP_DIR}/Contents/MacOS/"
if [ -f "${ICON_NAME}" ]; then
    cp "${ICON_NAME}" "${APP_DIR}/Contents/Resources/"
    echo "🎨 AppIcon included."
fi

# 7. 生成完整的 Info.plist
echo "📝 Generating full Info.plist..."
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
    <key>CFBundleDisplayName</key>
    <string>${APP_NAME}</string>
    <key>CFBundleIconFile</key>
    <string>${ICON_NAME}</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>${VERSION}</string>
    <key>CFBundleVersion</key>
    <string>${BUILD_NUMBER}</string>
    <key>LSMinimumSystemVersion</key>
    <string>14.0</string>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>NSHumanReadableCopyright</key>
    <string>Copyright © 2026 QuickGif Contributors. MIT License.</string>
    <key>CFBundleDocumentTypes</key>
    <array>
        <dict>
            <key>CFBundleTypeName</key>
            <string>Video Files</string>
            <key>LSHandlerRank</key>
            <string>Default</string>
            <key>LSItemContentTypes</key>
            <array>
                <string>public.mpeg-4</string>
                <string>com.apple.quicktime-movie</string>
            </array>
        </dict>
        <dict>
            <key>CFBundleTypeName</key>
            <string>Image Files</string>
            <key>LSHandlerRank</key>
            <string>Default</string>
            <key>LSItemContentTypes</key>
            <array>
                <string>public.jpeg</string>
                <string>public.png</string>
            </array>
        </dict>
    </array>
</dict>
</plist>
PLIST

# 8. 设置权限
chmod +x "${APP_DIR}/Contents/MacOS/${APP_NAME}"

# 9. 创建 DMG 安装包
echo "💿 Creating DMG installer: ${DMG_NAME}..."
rm -rf "${TEMP_DMG_DIR}"
rm -f "${DMG_NAME}"
mkdir -p "${TEMP_DMG_DIR}"
cp -R "${APP_DIR}" "${TEMP_DMG_DIR}/"
ln -s /Applications "${TEMP_DMG_DIR}/Applications"

hdiutil create -volname "${APP_NAME} Installer" -srcfolder "${TEMP_DMG_DIR}" -ov -format UDZO "${DMG_NAME}"

# 10. 清理临时文件夹
rm -rf "${TEMP_DMG_DIR}"
echo "✅ Done! ${DMG_NAME} created."
