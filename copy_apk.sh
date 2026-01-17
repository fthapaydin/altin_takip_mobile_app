#!/bin/bash
# APK'yı Flutter'ın beklediği konuma kopyala

APK_SOURCE="android/app/build/outputs/flutter-apk"
FLUTTER_OUTPUT="build/app/outputs/flutter-apk"

mkdir -p "$FLUTTER_OUTPUT"

if [ -f "$APK_SOURCE/app-debug.apk" ]; then
    cp "$APK_SOURCE/app-debug.apk" "$FLUTTER_OUTPUT/app-debug.apk"
    echo "✓ Debug APK copied to $FLUTTER_OUTPUT"
fi

if [ -f "$APK_SOURCE/app-release.apk" ]; then
    cp "$APK_SOURCE/app-release.apk" "$FLUTTER_OUTPUT/app-release.apk"
    echo "✓ Release APK copied to $FLUTTER_OUTPUT"
fi

