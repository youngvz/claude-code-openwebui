# Claude Code + OpenWebUI Integration

## Project Definition

A lightweight configuration repo for integrating Claude Code with a private, self-hosted LLM stack using OpenWebUI and Claude Code Router.

## Overview

This project enables seamless integration between Claude Code, a powerful CLI tool for AI-assisted coding, and OpenWebUI, a self-hosted web interface for interacting with Large Language Models (LLMs). The integration is facilitated by Claude Code Router (CCR) and managed through a simplified setup process using a single script.

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
4. Bash or Zsh shell

## Installation and Setup

### 1. Make the scripts executable

First, make the setup script and strip-reasoning proxy executable:

```bash
chmod +x /path/to/repo/scripts/claude-setup.sh
chmod +x /path/to/repo/scripts/strip-reasoning-proxy.mjs
```

Replace `/path/to/repo/scripts/` with the actual path to the `scripts` directory in your project.

### 2. Install Claude Code and Claude Code Router

If you haven't already installed Claude Code and Claude Code Router, follow these steps:

1. Install Claude Code:
   ```bash
   npm install -g @anthropic-ai/claude-code
   ```

2. Install Claude Code Router:
   ```bash
   npm install -g claude-code-router
   ```

### 3. Run the installation wizard

Use the `claude-setup.sh` script to run the installation wizard:

```bash
/path/to/repo/scripts/claude-setup.sh --install
```

This wizard will:
- Create a `.claude_env` file in your home directory with necessary environment variables
- Guide you through the initial setup process
- Configure all necessary components, including Claude Code Router and the optional strip-reasoning proxy

### 4. Start the Claude environment

After completing the installation, you can start the Claude environment using:

```bash
/path/to/repo/scripts/claude-setup.sh --start
```

This command will:
1. Start the strip-reasoning proxy (if needed)
2. Initialize Claude Code Router
3. Launch Claude Code

You're now ready to use Claude Code with your self-hosted LLM stack!

## Using claude-setup.sh

The `claude-setup.sh` script provides several options for managing your Claude environment:

- `--install`: Run the installation wizard for first-time setup
- `--start`: Start the Claude environment
- `--config`: Manage configuration settings
- `--status`: Check the status of Claude services
- `--update`: Update Claude components
- `--cleanup`: Perform cleanup procedures
- `--help`: Display help information

For example, to check the status of your Claude services:

```bash
/path/to/repo/scripts/claude-setup.sh --status
```

## Troubleshooting

1. **400 errors related to request shape**:
   - The `claude-setup.sh` script automatically manages the strip-reasoning proxy. If you encounter this error, try restarting the environment using `claude-setup.sh --start`.

2. **Authentication errors**:
   - Verify that your OpenWebUI API key is set correctly in the `.claude_env` file.
   - You can update your configuration using `claude-setup.sh --config`.

3. **Connection refused errors**:
   - Make sure OpenWebUI is running and accessible at the configured URL.
   - Check if any firewalls or network settings are blocking the connection.

4. **Unexpected model behavior**:
   - If you experience issues related to cached prompts, try enabling `DISABLE_PROMPT_CACHING=1` in your `.claude_env` file.
   - Verify that the selected model in the CCR config matches an available model in OpenWebUI.

5. **Issues with the startup script**:
   - Check the console output for any error messages.
   - Run `claude-setup.sh --status` to diagnose any component issues.
   - Ensure that the `OPENWEBUI_URL` and `OPENWEBUI_KEY` environment variables are set correctly in your `.claude_env` file.

For more detailed troubleshooting and the latest updates, please refer to the official documentation for [Claude Code](https://github.com/anthropics/claude-code), [Claude Code Router](https://github.com/musistudio/claude-code-router), and [OpenWebUI](https://github.com/openwebui/openwebui).

## Additional Resources

- [Claude Code Documentation](https://docs.anthropic.com/claude/docs)
- [OpenWebUI Documentation](https://docs.openwebui.com/)
- [Claude Code Router README](https://github.com/musistudio/claude-code-router/blob/main/README.md)

For any further assistance or to report issues, please open an issue in this repository.