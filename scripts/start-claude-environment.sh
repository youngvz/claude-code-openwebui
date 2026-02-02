#!/bin/bash

# Set up environment variables
if [ -z "$OPENWEBUI_URL" ]; then
    echo "Error: OPENWEBUI_URL is not set. Please set it before running this script."
    exit 1
fi

export UPSTREAM_URL="$OPENWEBUI_URL/api/v1/chat/completions"

# Start strip-reasoning proxy in the background
node $(dirname "$0")/strip-reasoning-proxy.mjs &
PROXY_PID=$!

# Run start-ccr function
start-ccr

# Launch Claude
claude

# Clean up: kill the proxy when Claude exits
kill $PROXY_PID