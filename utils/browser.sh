#!/bin/bash

open_browser() { 
    local url="$1"
    local display_name="$2"
    if command -v xdg-open &> /dev/null; then
        xdg-open "$url"
    elif command -v open &> /dev/null; then
        open "$url"
    else
        print_info "Manually visit $display_name URL: $url"
    fi
}