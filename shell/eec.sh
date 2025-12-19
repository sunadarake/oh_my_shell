#!/bin/sh
# eec - Chromeを起動

case "$(uname -s)" in
    Linux*)
        if command -v google-chrome >/dev/null 2>&1; then
            google-chrome "$@" >/dev/null 2>&1 &
        elif command -v chromium-browser >/dev/null 2>&1; then
            chromium-browser "$@" >/dev/null 2>&1 &
        elif command -v chromium >/dev/null 2>&1; then
            chromium "$@" >/dev/null 2>&1 &
        else
            echo "Chromeが見つかりません"
            exit 1
        fi
        ;;
    Darwin*)
        open -a "Google Chrome" "$@" >/dev/null 2>&1
        ;;
    MINGW*|Windows*)
        start chrome "$@"
        ;;
    *)
        echo "unknown OS"
        exit 1
        ;;
esac
