#!/bin/sh
# eei - Inkscapeを起動

case "$(uname -s)" in
    Linux*)
        if command -v inkscape >/dev/null 2>&1; then
            inkscape "$@" >/dev/null 2>&1 &
        else
            echo "Inkscapeが見つかりません"
            exit 1
        fi
        ;;
    Darwin*)
        open -a "Inkscape" "$@" >/dev/null 2>&1
        ;;
    MINGW*|Windows*)
        start inkscape "$@"
        ;;
    *)
        echo "unknown OS"
        exit 1
        ;;
esac
