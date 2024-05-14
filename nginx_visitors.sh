#!/bin/bash

# Summarizes and saves nginx ips from log, with help of ipinfo.
# Use argument "-e" for errors log.
# Access log will be used by default.
# If "ipinfo" is not installed, it will be prompted for MacOS or Debian.

verify_ipinfo_cli() {
    if ! command -v ipinfo &> /dev/null; then
        echo "ipinfo is not installed. Do you want to install it? [y/n]"
        read -r answer
        if [[ "$answer" != "y" ]]; then
            exit 1
        fi
        if [[ "$OSTYPE" == "darwin"* ]]; then
            curl -Ls https://github.com/ipinfo/cli/releases/download/ipinfo-3.3.1/macos.sh | sh
        elif [[ -f /etc/debian_version ]]; then
            curl -Ls https://github.com/ipinfo/cli/releases/download/ipinfo-3.3.1/deb.sh | sh
        else
            exit 1
        fi
    fi
}

verify_nginx_log() {
    if [ ! -s "$1" ]; then
        echo "Invalid nginx log."
        exit 1
    else
        echo "Processing '$1' ..."
    fi
}

process_nginx_logs() {
    ips=$(awk '{print $1}' "$LOG_PATH")
    response=$(echo "$ips" | curl -s -XPOST --data-binary @- "ipinfo.io/tools/summarize-ips?cli=1")
    reportUrl=$(echo "$response" | grep -oP '"reportUrl":\s*"\K[^"]+')
    echo "$ips" | ipinfo summarize > "$SUMMARY_PATH"
    if [ $? -eq 0 ]; then
        echo "Finished summary $SUMMARY_PATH ($(du -h "$SUMMARY_PATH" | cut -f1))"
        echo "$reportUrl"
    else
        exit 1
    fi
}

if [ "$1" == "-e" ]; then LOG_TYPE="error"; else LOG_TYPE="access"; fi
readonly LOG_PATH="/var/log/nginx/${LOG_TYPE}.log"
readonly SUMMARY_PATH="nginx_summary.txt"

verify_ipinfo_cli
verify_nginx_log "$LOG_PATH"
process_nginx_logs
