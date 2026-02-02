# Claude Code + OpenWebUI

## Project Definition

A lightweight configuration repo for wiring Claude Code into a private, self-hosted LLM stack using OpenWebUI.

## Requirements

### OpenWebUI

You must have OpenWebUI running either locally or remotely

Examples:
```
Local: http://localhost:3000

Remote: https://openwebui.yourdomain.com
```
### OpenWebUI API Key

An API key must be enabled in OpenWebUI.
This key will be used by Claude Code Router for authentication.

## Installation

### Claude Code

Install Claude Code using the official installer and follow the setup instructions in the repo:

Repo: https://github.com/anthropics/claude-code

### Claude Code Router (CCR)

Install Claude Code Router, which sits between Claude Code and your OpenAI-compatible endpoint (OpenWebUI / LiteLLM):

Repo: https://github.com/musistudio/claude-code-router

Install globally via npm:
```
npm install -g @musistudio/claude-code-router
```

## Setup

### 1. Configure Claude Code Router

Navigate to the Claude Code Router config directory in your home folder. Create it if it does not exist:

```
cd ~
mkdir -p .claude-code-router
cd .claude-code-router
```

Create a config.json file with the following contents:

```
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
```

> Note: This config.json is configured to runthe strip-reasoning proxy, if you do **not** need to run you can point
> `api_base_url` directly at OpenWebUI
>
>
> Replace `http://127.0.0.1:3457` with `$OPENWEBUI_URL`


#### Helper cURL to list all models available through OpenWebUI

```
curl -s \
  -H "Authorization: Bearer $OPENWEBUI_KEY" \
  "$OPENWEBUI_URL/api/v1/models" \
| jq -r '.data[].id'
```

> This assumes you've set your environment variables in your shell. See following steps

### 2. Optional: Run the strip-reasoning proxy

Some Bedrock-backed model stacks reject requests when certain “reasoning” fields are included in the payload (for example: reasoning, reasoning_effort, etc). If you run into 400 errors related to request shape, you can run a small local proxy that removes those fields before forwarding the request upstream.

> This step is optional. If your model stack accepts the request payloads
> without error, you can skip this proxy and point Claude Code Router directly
> at OpenWebUI.


This proxy listens on:
```
http://127.0.0.1:3457/api/v1/chat/completions
```
…and forwards requests to your upstream OpenWebUI chat completions endpoint.

#### Create the proxy script

Create a file named strip-reasoning-proxy.mjs somewhere convenient (for example in this repo under scripts/):

#### Run the proxy

Set the upstream URL to your real OpenWebUI (or LiteLLM) endpoint and start the server:

```
export UPSTREAM_URL="$OPENWEBUI_URL/api/v1/chat/completions"
node strip-reasoning-proxy.mjs
```

### 3. Install shell configuration and start CCR

From the root of this repo, make the install script executable and run it:

```
chmod +x scripts/install-shell.sh
./scripts/install-shell.sh
```

> Note: `DISABLE_PROMPT_CACHING=1` is optional and model-dependent.
> Some models work correctly with prompt caching enabled. If you do not
> encounter issues related to cached prompts, this flag can be removed
> from `install-shell.sh`.

Reload your shell so the new function is available:

```
source ~/.zshrc   # or ~/.bashrc
```

Start Claude Code Router with the correct environment:
```
start-ccr
```

Once CCR is running, you can launch Claude Code:
```
claude
```

At this point, Claude Code routes all requests through Claude Code Router and OpenWebUI.