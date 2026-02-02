#!/usr/bin/env bash
set -e

# Decide which shell config to use
if [ -n "$ZSH_VERSION" ]; then
  RC_FILE="$HOME/.zshrc"
elif [ -n "$BASH_VERSION" ]; then
  RC_FILE="$HOME/.bashrc"
else
  echo "Unsupported shell. Please add manually."
  exit 1
fi

MARKER_START="# >>> claude-code-openwebui >>>"
MARKER_END="# <<< claude-code-openwebui <<<"

# Prevent duplicate installs
if grep -q "$MARKER_START" "$RC_FILE" 2>/dev/null; then
  echo "CCR config already present in $RC_FILE"
  exit 0
fi

cat <<'EOF' >> "$RC_FILE"

# >>> claude-code-openwebui >>>
# TODO: Replace these placeholder values with your actual OpenWebUI URL and API key
export OPENWEBUI_URL="https://openwebui.yourdomain.com"
export OPENWEBUI_KEY="xyz"

start-ccr() {
  echo "🔧 Setting OpenWebUI (upstream) env vars..."
  export OPENWEBUI_BASE_URL="$OPENWEBUI_URL"
  export OPENWEBUI_API_KEY="$OPENWEBUI_KEY"

  # Backward-compatible aliases
  export OPENWEBUI_URL="$OPENWEBUI_BASE_URL"
  export OPENWEBUI_KEY="$OPENWEBUI_API_KEY"

  echo "🔀 Setting CCR / Claude Code env vars..."
  unset ANTHROPIC_AUTH_TOKEN
  export ANTHROPIC_BASE_URL="http://127.0.0.1:3456"
  export ANTHROPIC_API_KEY="sk-ant-ccr-proxy"
  export DISABLE_PROMPT_CACHING=1

  echo "♻️  Restarting Claude Code Router..."
  ccr restart

  echo "✅ CCR ready"
  echo "   ANTHROPIC_BASE_URL = $ANTHROPIC_BASE_URL"
}
# <<< claude-code-openwebui <<<

EOF

echo "✅ Added CCR config to $RC_FILE"
echo "👉 Restart your terminal or run: source $RC_FILE"
