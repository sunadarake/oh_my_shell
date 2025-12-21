#!/bin/bash
# cll - ターミナル画面をクリア

case "$(uname -s)" in
    Linux*)
        clear
        ;;
    Darwin*)
        clear
        ;;
    MINGW*|Windows*)
        clear
        ;;
    *)
        clear
        ;;
esac
