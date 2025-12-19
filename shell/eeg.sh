#!/bin/sh
# eeg - GIMPを起動

case "$(uname -s)" in
    Linux*)
        if command -v gimp >/dev/null 2>&1; then
            gimp "$@" >/dev/null 2>&1 &
        else
            echo "GIMPが見つかりません"
            exit 1
        fi
        ;;
    Darwin*)
        open -a "GIMP" "$@" >/dev/null 2>&1
        ;;
    MINGW*|Windows*)
        start gimp "$@"
        ;;
    *)
        echo "unknown OS"
        exit 1
        ;;
esac
