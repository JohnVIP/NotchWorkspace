#!/usr/bin/env bash
# Verify the built personal bundle without launching it.
set -euo pipefail

app=${1:?usage: scripts/check-isolation.sh /path/to/NotchWorkspace.app}
plist="$app/Contents/Info.plist"
read_key() { /usr/libexec/PlistBuddy -c "Print $1" "$plist"; }

[[ "$(basename "$app")" == NotchWorkspace.app ]]
[[ "$(read_key :CFBundleExecutable)" == NotchWorkspace ]]
[[ "$(read_key :CFBundleIdentifier)" == io.github.johnvip.notchworkspace ]]
[[ "$(read_key :CFBundleURLTypes:0:CFBundleURLName)" == io.github.johnvip.notchworkspace ]]
[[ "$(read_key :CFBundleURLTypes:0:CFBundleURLSchemes:0)" == notchworkspace ]]
for key in :SUFeedURL :SUPublicEDKey :OpenNotchSourceDirectory :CFBundleURLTypes:1 :CFBundleURLTypes:0:CFBundleURLSchemes:1; do
    if read_key "$key" >/dev/null 2>&1; then
        echo "Unexpected isolation key in Info.plist: $key" >&2
        exit 1
    fi
done
if [[ -d "$app/Contents/Frameworks/Sparkle.framework" ]]; then
    echo "Sparkle is still embedded" >&2
    exit 1
fi
codesign --verify --strict "$app"
echo "Notch Workspace bundle isolation OK"
