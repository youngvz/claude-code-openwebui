# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This repository contains a lightweight configuration for integrating Claude Code with a private, self-hosted LLM stack using OpenWebUI.

## Architecture

The project architecture consists of the following components:

1. Claude Code: The main CLI tool for interacting with the LLM.
2. Claude Code Router (CCR): Acts as an intermediary between Claude Code and the OpenAI-compatible endpoint (OpenWebUI / LiteLLM).
3. OpenWebUI: A self-hosted web interface for interacting with LLMs.
4. Optional: strip-reasoning proxy: A small local proxy that removes certain fields from requests before forwarding them to OpenWebUI.

## Setup and Configuration

1. Claude Code Router (CCR) Configuration:
   - Configuration file: `~/.claude-code-router/config.json`
   - Key settings:
     - API base URL: `http://127.0.0.1:3457/api/v1/chat/completions` (when using strip-reasoning proxy)
     - API key: Stored in `$OPENWEBUI_KEY` environment variable
     - Models: Configured in the "Providers" section of the config file

2. Optional strip-reasoning proxy:
   - Script: `strip-reasoning-proxy.mjs`
   - Listens on: `http://127.0.0.1:3457/api/v1/chat/completions`
   - Forwards requests to: `$OPENWEBUI_URL/api/v1/chat/completions`

3. Environment Setup:
   - The `install-shell.sh` script in the `scripts/` directory sets up the necessary environment variables and shell functions.
   - It also adds the `start-claude-environment.sh` script to your PATH for simplified startup.

## Common Commands

1. Start the entire Claude Code environment (new simplified method):
   ```
   start-claude-environment
   ```
   This command starts the strip-reasoning proxy (if needed), initializes Claude Code Router, and launches Claude Code.

2. Start Claude Code Router (if you need to start components separately):
   ```
   start-ccr
   ```

3. Launch Claude Code (if you need to start components separately):
   ```
   claude
   ```

4. List available models through OpenWebUI:
   ```
   curl -s -H "Authorization: Bearer $OPENWEBUI_KEY" "$OPENWEBUI_URL/api/v1/models" | jq -r '.data[].id'
   ```

## Development Notes

- When modifying the Claude Code Router configuration, update the `~/.claude-code-router/config.json` file.
- If encountering issues related to request payloads being rejected, the strip-reasoning proxy is automatically used by the `start-claude-environment` command.
- The `DISABLE_PROMPT_CACHING=1` environment variable is set in the `install-shell.sh` script. This can be removed if prompt caching doesn't cause issues with your specific model setup.
- The `start-claude-environment.sh` script manages the startup of all components, including the strip-reasoning proxy, CCR, and Claude Code.

Remember to refer to the official documentation for Claude Code, Claude Code Router, and OpenWebUI for more detailed information on each component.