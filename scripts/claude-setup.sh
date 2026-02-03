#!/bin/bash

set -e

# Function to display help information
show_help() {
    echo "Usage: $0 [OPTION]"
    echo "Manage Claude environment setup and execution."
    echo ""
    echo "Options:"
    echo "  --install   Run the installation wizard for first-time setup"
    echo "  --start     Start the Claude environment"
    echo "  --config    Manage configuration settings"
    echo "  --status    Check the status of Claude services"
    echo "  --update    Update Claude components"
    echo "  --cleanup   Perform cleanup procedures"
    echo "  --help      Display this help message"
}

# Function to run the installation wizard
run_install_wizard() {
    echo "Running installation wizard..."

    # Create .env file
    ENV_FILE="$HOME/.claude_env"
    if ! touch "$ENV_FILE"; then
        echo "Error: Unable to create $ENV_FILE"
        return 1
    fi

    # Prompt for OpenWebUI URL
    read -p "Enter OpenWebUI URL (default: http://localhost:8080): " OPENWEBUI_URL
    OPENWEBUI_URL=${OPENWEBUI_URL:-http://localhost:8080}
    echo "OPENWEBUI_URL=$OPENWEBUI_URL" >> "$ENV_FILE" || { echo "Error: Unable to write to $ENV_FILE"; return 1; }

    # Set UPSTREAM_URL based on OPENWEBUI_URL
    UPSTREAM_URL="${OPENWEBUI_URL}/api/v1/chat/completions"
    echo "UPSTREAM_URL=$UPSTREAM_URL" >> "$ENV_FILE" || { echo "Error: Unable to write to $ENV_FILE"; return 1; }

    # Prompt for OpenWebUI API Key
    read -p "Enter OpenWebUI API Key: " OPENWEBUI_KEY
    echo "OPENWEBUI_KEY=$OPENWEBUI_KEY" >> "$ENV_FILE" || { echo "Error: Unable to write to $ENV_FILE"; return 1; }

    # Add additional environment variables
    echo "ANTHROPIC_BASE_URL=http://127.0.0.1:3456" >> "$ENV_FILE"
    echo "ANTHROPIC_API_KEY=sk-ant-ccr-proxy" >> "$ENV_FILE"
    echo "DISABLE_PROMPT_CACHING=1" >> "$ENV_FILE"

    # Set up Claude Code Router configuration
    CCR_CONFIG_DIR="$HOME/.claude-code-router"
    if ! mkdir -p "$CCR_CONFIG_DIR"; then
        echo "Error: Unable to create $CCR_CONFIG_DIR"
        return 1
    fi

    if ! cat > "$CCR_CONFIG_DIR/config.json" << EOL
{
  "LOG": true,
  "LOG_LEVEL": "debug",
  "HOST": "127.0.0.1",
  "PORT": 3456,
  "API_TIMEOUT_MS": 600000,

  "Providers": [
    {
      "name": "openwebui",
      "api_base_url": "http://127.0.0.1:3457/api/v1/chat/completions",
      "api_key": "$OPENWEBUI_KEY",
      "models": ["claude-3.5-sonnet"]
    }
  ],

  "Router": {
    "default": "openwebui,claude-3.5-sonnet",
    "background": "openwebui,claude-3.5-sonnet",
    "think": "openwebui,claude-3.5-sonnet",
    "longContext": "openwebui,claude-3.5-sonnet"
  }
}
EOL
    then
        echo "Error: Unable to create config.json"
        return 1
    fi

    echo "Installation complete. Please restart your terminal or run 'source $ENV_FILE'."
    return 0
}

# Function to start the Claude environment
start_environment() {
    echo "Starting Claude environment..."

    # Load environment variables
    if [ -f "$HOME/.claude_env" ]; then
        source "$HOME/.claude_env"
    else
        echo "Error: Environment file not found. Please run --install first."
        exit 1
    fi

    # Start strip-reasoning proxy
    SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
    node "$SCRIPT_DIR/strip-reasoning-proxy.mjs" &
    STRIP_PROXY_PID=$!

    # Start Claude Code Router
    start-ccr &
    CCR_PID=$!

    # Wait for services to start
    sleep 5

    # Check if services are running
    if ! curl -s http://127.0.0.1:3457/health > /dev/null; then
        echo "Error: strip-reasoning proxy failed to start."
        kill $STRIP_PROXY_PID $CCR_PID
        exit 1
    fi

    if ! curl -s http://127.0.0.1:3456 > /dev/null; then
        echo "Error: Claude Code Router failed to start."
        kill $STRIP_PROXY_PID $CCR_PID
        exit 1
    fi

    echo "Claude environment started successfully."
    echo "You can now run 'claude' to start the Claude Code CLI."

    # Don't wait for background processes, allow the script to finish
    disown $STRIP_PROXY_PID
    disown $CCR_PID
}

# Function to manage configuration
manage_config() {
    echo "Managing configuration..."
    # TODO: Implement configuration management
}

# Function to check service status
check_status() {
    echo "Checking service status..."

    # Check strip-reasoning proxy
    if curl -s http://127.0.0.1:3457/health > /dev/null; then
        echo "strip-reasoning proxy: Running"
    else
        echo "strip-reasoning proxy: Not running"
    fi

    # Check Claude Code Router
    if curl -s http://127.0.0.1:3456 > /dev/null; then
        echo "Claude Code Router: Running"
    else
        echo "Claude Code Router: Not running"
    fi

    # Check OpenWebUI
    if [ -f "$HOME/.claude_env" ]; then
        source "$HOME/.claude_env"
        if curl -s -H "Authorization: Bearer $OPENWEBUI_KEY" "$OPENWEBUI_URL/api/v1/models" > /dev/null; then
            echo "OpenWebUI: Accessible"
        else
            echo "OpenWebUI: Not accessible"
        fi
    else
        echo "OpenWebUI: Unable to check (environment file not found)"
    fi
}

# Function to update components
update_components() {
    echo "Updating Claude components..."
    # TODO: Implement update mechanism
}

# Function to perform cleanup
perform_cleanup() {
    echo "Performing cleanup..."
    # TODO: Implement cleanup procedures
}

# Main script logic
case "$1" in
    --install)
        if ! run_install_wizard; then
            echo "Error: Installation failed"
            exit 1
        fi
        ;;
    --start)
        if ! start_environment; then
            echo "Error: Failed to start environment"
            exit 1
        fi
        ;;
    --config)
        if ! manage_config; then
            echo "Error: Configuration management failed"
            exit 1
        fi
        ;;
    --status)
        if ! check_status; then
            echo "Error: Status check failed"
            exit 1
        fi
        ;;
    --update)
        if ! update_components; then
            echo "Error: Update failed"
            exit 1
        fi
        ;;
    --cleanup)
        if ! perform_cleanup; then
            echo "Error: Cleanup failed"
            exit 1
        fi
        ;;
    --help)
        show_help
        ;;
    *)
        echo "Error: Invalid option. Use --help for usage information."
        exit 1
        ;;
esac