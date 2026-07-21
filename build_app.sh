#!/bin/bash
set -e

APP_NAME="Clocked"
BUNDLE="$APP_NAME.app"

swift build -c release

rm -rf "$BUNDLE"
mkdir -p "$BUNDLE/Contents/MacOS"
mkdir -p "$BUNDLE/Contents/Resources"

cp ".build/release/$APP_NAME" "$BUNDLE/Contents/MacOS/"
cp AppIcon.icns "$BUNDLE/Contents/Resources/"
cp Info.plist "$BUNDLE/Contents/"

codesign --force --deep --sign - "$BUNDLE"

echo "Built $BUNDLE — copy to /Applications to install"