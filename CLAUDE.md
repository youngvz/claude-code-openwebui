# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This repository contains a lightweight configuration for integrating Claude Code with a private, self-hosted LLM stack using OpenWebUI and Claude Code Router.

## Architecture

The project architecture consists of the following components:

1. Claude Code: The main CLI tool for interacting with the LLM.
2. Claude Code Router (CCR): Acts as an intermediary between Claude Code and the OpenAI-compatible endpoint (OpenWebUI / LiteLLM).
3. OpenWebUI: A self-hosted web interface for interacting with LLMs.
4. Optional: strip-reasoning proxy: A small local proxy that removes certain fields from requests before forwarding them to OpenWebUI.

## Setup and Configuration

1. Make the setup script executable:
   ```
   chmod +x /path/to/repo/scripts/claude-setup.sh
   ```
   Replace `/path/to/repo/scripts/` with the actual path to the `scripts` directory in your project.

2. Run the installation wizard:
   ```
   /path/to/repo/scripts/claude-setup.sh --install
   ```
   This wizard will:
   - Create a `.claude_env` file in your home directory with necessary environment variables
   - Guide you through the initial setup process
   - Install and configure all necessary components, including Claude Code Router and the optional strip-reasoning proxy

## Common Commands

1. Start the entire Claude Code environment:
   ```
   /path/to/repo/scripts/claude-setup.sh --start
   ```
   This command starts the strip-reasoning proxy (if needed), initializes Claude Code Router, and launches Claude Code.

2. Check the status of Claude services:
   ```
   /path/to/repo/scripts/claude-setup.sh --status
   ```

3. Manage configuration settings:
   ```
   /path/to/repo/scripts/claude-setup.sh --config
   ```

4. Update Claude components:
   ```
   /path/to/repo/scripts/claude-setup.sh --update
   ```

5. List available models through OpenWebUI:
   ```
   curl -s -H "Authorization: Bearer $OPENWEBUI_KEY" "$OPENWEBUI_URL/api/v1/models" | jq -r '.data[].id'
   ```

## Development Notes

- The `claude-setup.sh` script manages all aspects of the Claude environment, including setup, configuration, and startup.
- Claude Code Router (CCR) configuration is handled automatically by the setup script.
- The optional strip-reasoning proxy is managed by the `claude-setup.sh` script and used when necessary.
- If encountering issues related to prompt caching, you can enable `DISABLE_PROMPT_CACHING=1` in your `.claude_env` file.
- For detailed configuration options and troubleshooting, refer to the README.md file in this repository.

Remember to refer to the official documentation for Claude Code, Claude Code Router, and OpenWebUI for more detailed information on each component.