#!/usr/bin/env bash
set -e

SCOPE="${1:-global}"
TARGET_PATH="$2"

SOURCE_DIR=""
if [ -n "${BASH_SOURCE[0]}" ] && [ -f "$(dirname "${BASH_SOURCE[0]}")/SKILL.md" ]; then
    SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
fi

TEMP_CLEANUP=""
INSTALL_METHOD="link"

if [ -z "$SOURCE_DIR" ] || [ ! -f "$SOURCE_DIR/SKILL.md" ]; then
    echo "Remote installer mode detected. Fetching latest release from GitHub..."
    TEMP_CLEANUP="$(mktemp -d)"
    curl -fsSL "https://github.com/qanh10x10/casual-game-kit/archive/refs/heads/main.tar.gz" | tar -xz -C "$TEMP_CLEANUP"
    SOURCE_DIR="$TEMP_CLEANUP/casual-game-kit-main"
    INSTALL_METHOD="copy"
fi

cleanup() {
    if [ -n "$TEMP_CLEANUP" ] && [ -d "$TEMP_CLEANUP" ]; then
        rm -rf "$TEMP_CLEANUP"
    fi
}
trap cleanup EXIT

echo "Source skill directory: $SOURCE_DIR"

install_dir() {
    local dest="$1"
    local src="$2"
    local method="$3"

    mkdir -p "$(dirname "$dest")"
    rm -rf "$dest"

    if [ "$method" = "link" ]; then
        ln -sfn "$src" "$dest"
        echo "[OK] Linked: $dest -> $src"
    else
        cp -R "$src" "$dest"
        echo "[OK] Copied permanently: $dest"
    fi
}

if [ "$SCOPE" = "global" ]; then
    echo "=== Installing Globally for Current User ==="
    
    # 1. ~/.agents/skills (GitHub Copilot, Codex, Roo, Antigravity)
    install_dir "$HOME/.agents/skills/casual-game-kit" "$SOURCE_DIR" "$INSTALL_METHOD"
    install_dir "$HOME/.agents/skills/puzzle-game-ui" "$SOURCE_DIR" "$INSTALL_METHOD"

    # 2. ~/.claude/skills (Claude Code)
    install_dir "$HOME/.claude/skills/casual-game-kit" "$SOURCE_DIR" "$INSTALL_METHOD"
    install_dir "$HOME/.claude/skills/puzzle-game-ui" "$SOURCE_DIR" "$INSTALL_METHOD"

    # 3. ~/.codex/skills (OpenAI Codex)
    install_dir "$HOME/.codex/skills/casual-game-kit" "$SOURCE_DIR" "$INSTALL_METHOD"
    install_dir "$HOME/.codex/skills/puzzle-game-ui" "$SOURCE_DIR" "$INSTALL_METHOD"

    # Optional: configure npm allow-git if npm exists
    if command -v npm >/dev/null 2>&1; then
        CURRENT_ALLOW="$(npm config get allow-git 2>/dev/null || true)"
        if [ "$CURRENT_ALLOW" = "none" ]; then
            npm config set allow-git all >/dev/null 2>&1 || true
            echo "[INFO] Configured npm allow-git = all"
        fi
    fi

    echo "Global install complete!"
elif [ "$SCOPE" = "project" ]; then
    if [ -z "$TARGET_PATH" ] || [ ! -d "$TARGET_PATH" ]; then
        echo "Error: please provide a valid target directory as 2nd argument."
        exit 1
    fi
    TARGET_ABS="$(cd "$TARGET_PATH" && pwd)"
    echo "=== Installing into Project: $TARGET_ABS ==="

    # .agents/skills
    install_dir "$TARGET_ABS/.agents/skills/casual-game-kit" "$SOURCE_DIR" "$INSTALL_METHOD"

    # .claude/skills
    install_dir "$TARGET_ABS/.claude/skills/casual-game-kit" "$SOURCE_DIR" "$INSTALL_METHOD"

    # Cursor
    mkdir -p "$TARGET_ABS/.cursor/rules"
    cp -f "$SOURCE_DIR/adapters/cursor/casual-game-kit.mdc" "$TARGET_ABS/.cursor/rules/"

    # Windsurf
    if [ ! -f "$TARGET_ABS/.windsurfrules" ]; then
        cp "$SOURCE_DIR/adapters/windsurf/.windsurfrules" "$TARGET_ABS/.windsurfrules"
    fi

    # Gemini / Antigravity
    if [ ! -f "$TARGET_ABS/GEMINI.md" ]; then
        cp "$SOURCE_DIR/adapters/gemini-antigravity/GEMINI.md" "$TARGET_ABS/GEMINI.md"
    fi
    mkdir -p "$TARGET_ABS/.gemini"
    cp -f "$SOURCE_DIR/adapters/gemini-antigravity/rules.md" "$TARGET_ABS/.gemini/rules.md"

    # Cline
    if [ ! -f "$TARGET_ABS/.clinerules" ]; then
        cp "$SOURCE_DIR/adapters/cline/.clinerules" "$TARGET_ABS/.clinerules"
    fi

    # Continue.dev
    mkdir -p "$TARGET_ABS/.continue/prompts"
    cp -f "$SOURCE_DIR/adapters/continue/casual-game-kit.prompt" "$TARGET_ABS/.continue/prompts/"

    echo "Project install complete for $TARGET_ABS!"
fi
