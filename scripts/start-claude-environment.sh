#!/bin/bash

# Set up environment variables
if [ -z "$OPENWEBUI_URL" ] || [ -z "$OPENWEBUI_KEY" ] || [ -z "$DEV_WEBUI_KEY" ]; then
    echo "Error: OPENWEBUI_URL, OPENWEBUI_KEY, or DEV_WEBUI_KEY is not set. Please set them before running this script."
    exit 1
fi

export UPSTREAM_URL="$OPENWEBUI_URL/api/v1/chat/completions"

# Check if strip-reasoning proxy is already running
if ! curl -s http://127.0.0.1:3457 > /dev/null; then
    # Start strip-reasoning proxy in the background
    node $(dirname "$0")/strip-reasoning-proxy.mjs &
    PROXY_PID=$!

    # Wait for proxy to start
    sleep 2

    # Check if proxy is running
    if ! curl -s http://127.0.0.1:3457 > /dev/null; then
        echo "Error: strip-reasoning proxy failed to start"
        [ -n "$PROXY_PID" ] && kill $PROXY_PID
        exit 1
    fi
fi

# Run start-ccr function
start-ccr

# Wait for CCR to start
sleep 2

# Check if CCR is running
if ! curl -s http://127.0.0.1:3456 > /dev/null; then
    echo "Error: Claude Code Router failed to start"
    [ -n "$PROXY_PID" ] && kill $PROXY_PID
    exit 1
fi

echo "Environment setup complete."
echo "To start Claude, run the 'claude' command in a new terminal."
