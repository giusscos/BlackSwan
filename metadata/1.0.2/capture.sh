#!/bin/zsh
# Captures raw App Store screens for every language on an iPhone and an iPad simulator.
# Usage: metadata/1.0.2/capture.sh <path to Debug-iphonesimulator BlackSwan.app>
# Output: metadata/1.0.2/raw/<device>/<language>/<screen>.png
set -euo pipefail

APP="$1"
OUT="${0:A:h}/raw"
BUNDLE="giusscos.BlackSwan"
LANGUAGES=(en de es fr it)
SCREENS=(${=SCREENS_OVERRIDE:-home detail fragility review premortem paywall})
# name:UDID. iPhone 17 Pro and iPad Pro 11-inch (M5) match the device bezels in Figma.
DEVICES=(iphone:F7939337-F961-48C8-9199-1CA8251CBB9B ipad:E7264D6D-1E4D-4EA5-BD86-C90464DE5E4E)

typeset -A LOCALES=(en en_US de de_DE es es_ES fr fr_FR it it_IT)

for entry in $DEVICES; do
    device=${entry%%:*}
    udid=${entry#*:}
    # ONLY=ipad (or iphone) re-runs a single device.
    [[ -n "${ONLY:-}" && "$device" != "$ONLY" ]] && continue
    xcrun simctl boot "$udid" 2>/dev/null || true
    xcrun simctl bootstatus "$udid" -b >/dev/null
    sleep 10  # a freshly booted simulator can refuse installs for a few seconds
    xcrun simctl status_bar "$udid" override --time "9:41" --batteryState charged --batteryLevel 100 --cellularBars 4 --wifiBars 3
    xcrun simctl install "$udid" "$APP"

    for lang in $LANGUAGES; do
        mkdir -p "$OUT/$device/$lang"
        for screen in $SCREENS; do
            # A clean stop before relaunching avoids an occasional blank first frame on iPad.
            xcrun simctl terminate "$udid" "$BUNDLE" 2>/dev/null || true
            sleep 2
            xcrun simctl launch "$udid" "$BUNDLE" \
                -AppleLanguages "($lang)" -AppleLocale "${LOCALES[$lang]}" \
                -ScreenshotScreen "$screen" -SimulatorSubscribed YES -focusThemes money >/dev/null
            # The weekly review waits for an on-device summary; the demo animates its checklist.
            case $screen in
                review) sleep 16 ;;
                demo) sleep 10 ;;
                *) sleep 8 ;;
            esac
            xcrun simctl io "$udid" screenshot "$OUT/$device/$lang/$screen.png" >/dev/null 2>&1
            echo "$device/$lang/$screen"
        done
    done
    xcrun simctl terminate "$udid" "$BUNDLE" 2>/dev/null || true
done
