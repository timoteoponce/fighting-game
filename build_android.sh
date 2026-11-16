#!/usr/bin/env bash
# Builds the Android APK into build/android/ (PJsClash.apk).
#
# Needs, on top of the export templates the other builds need:
#   * a JDK on the PATH (keytool generates the keystore, apksigner runs on Java)
#   * the Android SDK with build-tools installed, and Editor Settings >
#     Export > Android in the Godot editor pointing at both (once per machine;
#     CI writes that settings file itself)
#
# Signing: GODOT_ANDROID_KEYSTORE_RELEASE_PATH / _USER / _PASSWORD win when
# set (CI injects the stable key from secrets, so installs can upgrade). A
# fresh checkout without them gets a self-signed keystore in build/android/ —
# every machine its own key, so those installs do not upgrade over each other.
set -euo pipefail
cd "$(dirname "$0")"

GODOT="${GODOT:-godot}"
OUT=build/android
KS="$OUT/release.keystore"

if ! command -v keytool >/dev/null 2>&1; then
    echo "build_android.sh: no keytool on the PATH — install a JDK 17+ first." >&2
    exit 1
fi

if [ -z "${GODOT_ANDROID_KEYSTORE_RELEASE_PATH:-}" ]; then
    if [ ! -f "$KS" ]; then
        mkdir -p "$OUT"
        keytool -genkeypair -keystore "$KS" -storepass pjsclash -keypass pjsclash \
            -alias pjsclash -keyalg RSA -keysize 2048 -validity 10000 \
            -dname "CN=PJsClash" >/dev/null
        echo "build_android.sh: generated a self-signed $KS (unstable key; see header)"
    fi
    export GODOT_ANDROID_KEYSTORE_RELEASE_PATH="$PWD/$KS"
    export GODOT_ANDROID_KEYSTORE_RELEASE_USER=pjsclash
    export GODOT_ANDROID_KEYSTORE_RELEASE_PASSWORD=pjsclash
fi

"$GODOT" --headless --path . --import
"$GODOT" --headless --path . --export-release "Android" "$OUT/PJsClash.apk"
echo "Built $OUT/PJsClash.apk — install over adb or copy it to the phone."
