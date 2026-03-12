#!/bin/bash
set -euo pipefail

APP_NAME="NvimEdit"
APP_DIR="$HOME/Applications/${APP_NAME}.app"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BUNDLE_ID="com.atretyakov.nvimedit"

rm -rf "$APP_DIR"
mkdir -p "$APP_DIR/Contents/MacOS"

swiftc -O -o "$APP_DIR/Contents/MacOS/$APP_NAME" \
    "$SCRIPT_DIR/${APP_NAME}.swift" \
    -framework AppKit

cat > "$APP_DIR/Contents/Info.plist" << 'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>NvimEdit</string>
    <key>CFBundleIdentifier</key>
    <string>com.atretyakov.nvimedit</string>
    <key>CFBundleName</key>
    <string>NvimEdit</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleVersion</key>
    <string>1.0</string>
    <key>LSUIElement</key>
    <true/>
    <key>NSPrincipalClass</key>
    <string>NSApplication</string>
    <key>NSAppleEventsUsageDescription</key>
    <string>NvimEdit needs to control Ghostty to open files in Neovim.</string>
    <key>CFBundleDocumentTypes</key>
    <array>
        <dict>
            <key>CFBundleTypeName</key>
            <string>Source Code</string>
            <key>CFBundleTypeRole</key>
            <string>Editor</string>
            <key>LSItemContentTypes</key>
            <array>
                <string>public.source-code</string>
                <string>public.script</string>
                <string>public.shell-script</string>
            </array>
        </dict>
        <dict>
            <key>CFBundleTypeName</key>
            <string>Plain Text</string>
            <key>CFBundleTypeRole</key>
            <string>Editor</string>
            <key>LSItemContentTypes</key>
            <array>
                <string>public.plain-text</string>
                <string>public.utf8-plain-text</string>
            </array>
        </dict>
        <dict>
            <key>CFBundleTypeName</key>
            <string>Markup</string>
            <key>CFBundleTypeRole</key>
            <string>Editor</string>
            <key>LSItemContentTypes</key>
            <array>
                <string>net.daringfireball.markdown</string>
                <string>public.json</string>
                <string>public.xml</string>
                <string>public.yaml</string>
                <string>public.html</string>
                <string>public.xhtml</string>
                <string>public.comma-separated-values-text</string>
                <string>com.apple.property-list</string>
            </array>
        </dict>
        <dict>
            <key>CFBundleTypeName</key>
            <string>Other Code</string>
            <key>CFBundleTypeRole</key>
            <string>Editor</string>
            <key>CFBundleTypeExtensions</key>
            <array>
                <string>rs</string>
                <string>go</string>
                <string>ts</string>
                <string>tsx</string>
                <string>jsx</string>
                <string>toml</string>
                <string>kdl</string>
                <string>lua</string>
                <string>zig</string>
                <string>nix</string>
                <string>tf</string>
                <string>hcl</string>
                <string>proto</string>
                <string>graphql</string>
                <string>sql</string>
                <string>css</string>
                <string>scss</string>
                <string>less</string>
                <string>vue</string>
                <string>svelte</string>
                <string>mdx</string>
                <string>conf</string>
                <string>cfg</string>
                <string>ini</string>
                <string>env</string>
                <string>log</string>
            </array>
        </dict>
    </array>
</dict>
</plist>
PLIST

/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -f "$APP_DIR"

command -v duti &>/dev/null || brew install duti

UTIS=(
    public.plain-text
    public.utf8-plain-text
    public.source-code
    public.script
    public.shell-script
    public.json
    public.xml
    public.yaml
    public.html
    public.xhtml
    public.c-source
    public.c-header
    public.c-plus-plus-source
    public.objective-c-source
    public.swift-source
    public.python-script
    public.ruby-script
    public.perl-script
    public.php-script
    public.assembly-source
    net.daringfireball.markdown
    com.netscape.javascript-source
    com.sun.java-source
    com.apple.property-list
    public.comma-separated-values-text
)

EXTS=(rs go ts tsx jsx toml kdl lua zig nix tf hcl proto graphql sql css scss less vue svelte mdx conf cfg ini env log)

for uti in "${UTIS[@]}"; do
    duti -s "$BUNDLE_ID" "$uti" editor 2>/dev/null || true
done

for ext in "${EXTS[@]}"; do
    duti -s "$BUNDLE_ID" ".$ext" all 2>/dev/null || true
done

echo "Installed $APP_DIR"
echo "Set as default handler for text, source code, markup, and config files."
