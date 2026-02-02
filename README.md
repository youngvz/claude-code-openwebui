# Claude Code + OpenWebUI Integration

## Project Definition

A lightweight configuration repo for integrating Claude Code with a private, self-hosted LLM stack using OpenWebUI.

## Overview

This project enables seamless integration between Claude Code, a powerful CLI tool for AI-assisted coding, and OpenWebUI, a self-hosted web interface for interacting with Large Language Models (LLMs). The integration is facilitated by Claude Code Router (CCR), which acts as an intermediary between Claude Code and the OpenAI-compatible endpoint provided by OpenWebUI.

### System Architecture

```
┌──────────────┐    ┌──────────────┐    ┌─────────────────┐    ┌───────────┐
│  Claude Code │ -> │ Claude Code  │ -> │ strip-reasoning │ -> │ OpenWebUI │
│     CLI      │    │    Router    │    │     proxy       │    │           │
└──────────────┘    └──────────────┘    └─────────────────┘    └───────────┘
```

The strip-reasoning proxy is optional and can be bypassed if not needed.

## Prerequisites

Before setting up the integration, ensure you have the following:

1. OpenWebUI installed and running (locally or remotely)
2. An OpenWebUI API key
3. Node.js (v14.0.0+) and npm (v6.0.0+) installed on your system
4. Claude Code installed (version 1.0.0 or higher)
5. Claude Code Router (version 1.1.0 or higher)
6. Bash or Zsh shell

## Installation

### 1. Claude Code (v1.0.0+)

Install Claude Code using the official installer. The installation method may vary depending on your environment.

For detailed installation instructions and methods, visit the [Claude Code Setup Documentation](https://code.claude.com/docs/en/setup#installation).

After installation, verify your Claude Code version:

```
claude --version
```

Ensure you have version 1.0.0 or higher installed.

For more information and usage instructions, visit the [Claude Code repository](https://github.com/anthropics/claude-code).

### 2. Claude Code Router (CCR) (v1.1.0+)

Install Claude Code Router globally via npm:

```
npm install -g @musistudio/claude-code-router@1.1.0
```

For more information, visit the [Claude Code Router repository](https://github.com/musistudio/claude-code-router).

## Setup

### 1. Configure Claude Code Router

Use the provided CCR configuration file located in the `/config` folder of this repository:

- [CCR config.json](/config/config.json)

Copy this file to your Claude Code Router configuration directory:

```bash
mkdir -p ~/.claude-code-router
cp /path/to/repo/config/config.json ~/.claude-code-router/config.json
```

Note: This configuration assumes you're using the strip-reasoning proxy. If not needed, replace `http://127.0.0.1:3457` with your actual OpenWebUI URL.

### 2. Install shell configuration

Use the provided install script:

- [install-shell.sh](/scripts/install-shell.sh)

Run the install script:

```bash
chmod +x /path/to/repo/scripts/install-shell.sh
/path/to/repo/scripts/install-shell.sh
```

This script will update your shell configuration, set up the necessary environment variables and aliases, and add the new `start-claude-environment.sh` script to your PATH.

### 3. Set up environment variables

After running the install script, edit your `~/.bashrc` or `~/.zshrc` file to replace the placeholder values with your actual OpenWebUI URL and API key:

```bash
export OPENWEBUI_URL="http://your-openwebui-url:port"
export OPENWEBUI_KEY="your-openwebui-api-key"
```

### 4. Optional: Set up the strip-reasoning proxy

If your model stack rejects requests with certain fields, use the provided proxy script to remove them:

- [strip-reasoning-proxy.mjs](/scripts/strip-reasoning-proxy.mjs)

The script is already included in the repository and will be used automatically by the `start-claude-environment.sh` script.

## Getting Started

To start the entire Claude Code environment with a single command, use:

```bash
start-claude-environment
```

This command will:
1. Start the strip-reasoning proxy (if needed)
2. Initialize Claude Code Router (CCR)
3. Launch Claude Code

You're now ready to use Claude Code with your self-hosted LLM stack!

## Troubleshooting

1. **400 errors related to request shape**:
   - Ensure the strip-reasoning proxy is running and configured correctly.
   - Check if your OpenWebUI version is compatible with the current request format.

2. **Authentication errors**:
   - Verify that your OpenWebUI API key is set correctly in the environment variables.
   - Check if the API key is still valid in your OpenWebUI settings.

3. **Connection refused errors**:
   - Make sure OpenWebUI is running and accessible at the configured URL.
   - Check if any firewalls or network settings are blocking the connection.

4. **Unexpected model behavior**:
   - If you experience issues related to cached prompts, try enabling `DISABLE_PROMPT_CACHING=1`.
   - Verify that the selected model in the CCR config matches an available model in OpenWebUI.

5. **Issues with the combined startup script**:
   - Check the console output for any error messages.
   - Ensure all components (strip-reasoning proxy, CCR, Claude Code) are installed correctly.
   - Verify that the `OPENWEBUI_URL` and `OPENWEBUI_KEY` environment variables are set correctly.

For more detailed troubleshooting and the latest updates, please refer to the official documentation for [Claude Code](https://github.com/anthropics/claude-code), [Claude Code Router](https://github.com/musistudio/claude-code-router), and [OpenWebUI](https://github.com/openwebui/openwebui).

## Additional Resources

- [Claude Code Documentation](https://docs.anthropic.com/claude/docs)
- [OpenWebUI Documentation](https://docs.openwebui.com/)
- [Claude Code Router README](https://github.com/musistudio/claude-code-router/blob/main/README.md)

For any further assistance or to report issues, please open an issue in this repository.