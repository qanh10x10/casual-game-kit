#!/usr/bin/env bash
set -e

SCOPE="${1:-global}"
TARGET_PATH="$2"

SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "Source skill directory: $SOURCE_DIR"

if [ "$SCOPE" = "global" ]; then
    echo "=== Installing Globally for Current User ==="
    
    # 1. ~/.agents/skills (GitHub Copilot, Codex, Roo, Antigravity)
    AGENTS_DIR="$HOME/.agents/skills/casual-game-kit"
    mkdir -p "$HOME/.agents/skills"
    ln -sfn "$SOURCE_DIR" "$AGENTS_DIR"
    ln -sfn "$SOURCE_DIR" "$HOME/.agents/skills/puzzle-game-ui"
    echo "[OK] Linked to: $AGENTS_DIR"

    # 2. ~/.claude/skills (Claude Code)
    CLAUDE_DIR="$HOME/.claude/skills/casual-game-kit"
    mkdir -p "$HOME/.claude/skills"
    ln -sfn "$SOURCE_DIR" "$CLAUDE_DIR"
    ln -sfn "$SOURCE_DIR" "$HOME/.claude/skills/puzzle-game-ui"
    echo "[OK] Linked to: $CLAUDE_DIR"

    # 3. ~/.codex/skills (OpenAI Codex)
    CODEX_DIR="$HOME/.codex/skills/casual-game-kit"
    mkdir -p "$HOME/.codex/skills"
    ln -sfn "$SOURCE_DIR" "$CODEX_DIR"
    ln -sfn "$SOURCE_DIR" "$HOME/.codex/skills/puzzle-game-ui"
    echo "[OK] Linked to: $CODEX_DIR"

    echo "Global install complete!"
elif [ "$SCOPE" = "project" ]; then
    if [ -z "$TARGET_PATH" ] || [ ! -d "$TARGET_PATH" ]; then
        echo "Error: please provide a valid target directory as 2nd argument."
        exit 1
    fi
    TARGET_ABS="$(cd "$TARGET_PATH" && pwd)"
    echo "=== Installing into Project: $TARGET_ABS ==="

    # .agents/skills
    mkdir -p "$TARGET_ABS/.agents/skills"
    ln -sfn "$SOURCE_DIR" "$TARGET_ABS/.agents/skills/casual-game-kit"

    # .claude/skills
    mkdir -p "$TARGET_ABS/.claude/skills"
    ln -sfn "$SOURCE_DIR" "$TARGET_ABS/.claude/skills/casual-game-kit"

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
