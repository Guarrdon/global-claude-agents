#!/bin/bash
# ============================================
# Global Claude Agents - Install Script
# ============================================

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${BLUE}"
echo "╔════════════════════════════════════════════════╗"
echo "║     Global Claude Agents - Installer           ║"
echo "╚════════════════════════════════════════════════╝"
echo -e "${NC}"

# Get target directory
DEFAULT_TARGET="$HOME/.claude"
echo -e "${YELLOW}Where is your global Claude configuration directory?${NC}"
echo -e "Press Enter for default: ${GREEN}$DEFAULT_TARGET${NC}"
read -p "> " TARGET_DIR
TARGET_DIR="${TARGET_DIR:-$DEFAULT_TARGET}"
TARGET_DIR="${TARGET_DIR/#\~/$HOME}"

echo -e "\nTarget directory: ${GREEN}$TARGET_DIR${NC}"

# Create if needed
if [ ! -d "$TARGET_DIR" ]; then
    echo -e "${YELLOW}Target directory does not exist. Create it?${NC} [Y/n]"
    read -p "> " CREATE_DIR
    if [ "$CREATE_DIR" != "n" ] && [ "$CREATE_DIR" != "N" ]; then
        mkdir -p "$TARGET_DIR"
        echo -e "${GREEN}Created $TARGET_DIR${NC}"
    else
        echo -e "${RED}Aborted.${NC}"; exit 1
    fi
fi

# Backup
BACKUP_DIR="$TARGET_DIR/backups"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_PATH="$BACKUP_DIR/backup_$TIMESTAMP"
echo -e "\n${BLUE}Creating backup...${NC}"
mkdir -p "$BACKUP_PATH"

BACKUP_ITEMS=("CLAUDE.md" "CLAUDE.agents.md" "settings.json" "statusline.sh" "agents" "agents-bk" "commands")
BACKED_UP=0
for item in "${BACKUP_ITEMS[@]}"; do
    [ -e "$TARGET_DIR/$item" ] && cp -r "$TARGET_DIR/$item" "$BACKUP_PATH/" && BACKED_UP=$((BACKED_UP + 1))
done
[ $BACKED_UP -gt 0 ] && echo -e "${GREEN}Backed up $BACKED_UP items${NC}" || rmdir "$BACKUP_PATH" 2>/dev/null

# Helper function
copy_with_prompt() {
    local src="$1" dest="$2" name=$(basename "$1")
    if [ -e "$dest" ]; then
        [ -f "$src" ] && [ -f "$dest" ] && diff -q "$src" "$dest" >/dev/null 2>&1 && echo -e "  ${GREEN}✓${NC} $name (up to date)" && return
        echo -e "  ${YELLOW}?${NC} $name exists. Overwrite? [y/N/d]"
        read -p "    > " OW
        case "$OW" in
            y|Y) [ -d "$src" ] && rm -rf "$dest"; cp -r "$src" "$dest"; echo -e "    ${GREEN}Replaced${NC}";;
            d|D) [ -f "$src" ] && diff "$dest" "$src" || true; echo "    Overwrite? [y/N]"; read -p "    > " OW2
                 [ "$OW2" = "y" ] || [ "$OW2" = "Y" ] && cp "$src" "$dest" && echo -e "    ${GREEN}Replaced${NC}" || echo -e "    ${YELLOW}Skipped${NC}";;
            *) echo -e "    ${YELLOW}Skipped${NC}";;
        esac
    else
        cp -r "$src" "$dest"; echo -e "  ${GREEN}+${NC} $name (installed)"
    fi
}

# Install CLAUDE.agents.md (always - core agent system)
echo -e "\n${BLUE}Agent System:${NC}"
[ -f "$SCRIPT_DIR/CLAUDE.agents.md" ] && cp "$SCRIPT_DIR/CLAUDE.agents.md" "$TARGET_DIR/CLAUDE.agents.md" && echo -e "  ${GREEN}+${NC} CLAUDE.agents.md (agent system instructions)"

# Handle CLAUDE.md (smart merge)
echo -e "\n${BLUE}Global Instructions:${NC}"
if [ -f "$TARGET_DIR/CLAUDE.md" ]; then
    if grep -q "CLAUDE.agents.md" "$TARGET_DIR/CLAUDE.md"; then
        echo -e "  ${GREEN}✓${NC} CLAUDE.md already references agent system"
    else
        echo -e "  ${YELLOW}!${NC} CLAUDE.md exists but doesn't reference agents."
        echo "    [a] Append reference, [r] Replace, [s] Skip"
        read -p "    > " CA
        case "$CA" in
            a|A) echo -e "\n## Agent System\n\n**Read and follow all instructions in \`~/.claude/CLAUDE.agents.md\`**\n" >> "$TARGET_DIR/CLAUDE.md"
                 echo -e "    ${GREEN}Appended reference${NC}";;
            r|R) cp "$SCRIPT_DIR/CLAUDE.md" "$TARGET_DIR/CLAUDE.md"; echo -e "    ${GREEN}Replaced${NC}";;
            *) echo -e "    ${YELLOW}Skipped - add reference manually${NC}";;
        esac
    fi
else
    cp "$SCRIPT_DIR/CLAUDE.md" "$TARGET_DIR/CLAUDE.md"
    echo -e "  ${GREEN}+${NC} CLAUDE.md (template installed)"
fi

# Documentation
echo -e "\n${BLUE}Documentation:${NC}"
for doc in "AGENT_SELECTION_GUIDE.md" "DOCUMENTATION_AGENT_HIERARCHY.md" "DOC_MASTER_GUIDE.md" "SETUP_SUMMARY.md"; do
    [ -f "$SCRIPT_DIR/$doc" ] && copy_with_prompt "$SCRIPT_DIR/$doc" "$TARGET_DIR/$doc"
done

# Agents directory
echo -e "\n${BLUE}Agents:${NC}"
if [ -d "$SCRIPT_DIR/agents" ]; then
    if [ -d "$TARGET_DIR/agents" ]; then
        echo -e "  ${YELLOW}?${NC} agents/ exists. [m]erge, [r]eplace, [s]kip"
        read -p "    > " AA
        case "$AA" in
            m|M) cp -rn "$SCRIPT_DIR/agents/"* "$TARGET_DIR/agents/" 2>/dev/null || true
                 for sd in "$SCRIPT_DIR/agents/"*/; do [ -d "$sd" ] && mkdir -p "$TARGET_DIR/agents/$(basename "$sd")" && cp -rn "$sd"* "$TARGET_DIR/agents/$(basename "$sd")/" 2>/dev/null; done
                 echo -e "    ${GREEN}Merged${NC}";;
            r|R) rm -rf "$TARGET_DIR/agents"; cp -r "$SCRIPT_DIR/agents" "$TARGET_DIR/agents"; echo -e "    ${GREEN}Replaced${NC}";;
            *) echo -e "    ${YELLOW}Skipped${NC}";;
        esac
    else
        cp -r "$SCRIPT_DIR/agents" "$TARGET_DIR/agents"; echo -e "  ${GREEN}+${NC} agents/ (installed)"
    fi
fi

# Commands directory
echo -e "\n${BLUE}Commands:${NC}"
if [ -d "$SCRIPT_DIR/commands" ]; then
    if [ -d "$TARGET_DIR/commands" ]; then
        echo -e "  ${YELLOW}?${NC} commands/ exists. [m]erge, [r]eplace, [s]kip"
        read -p "    > " CA
        case "$CA" in
            m|M) cp -rn "$SCRIPT_DIR/commands/"* "$TARGET_DIR/commands/" 2>/dev/null || true
                 echo -e "    ${GREEN}Merged${NC}";;
            r|R) rm -rf "$TARGET_DIR/commands"; cp -r "$SCRIPT_DIR/commands" "$TARGET_DIR/commands"; echo -e "    ${GREEN}Replaced${NC}";;
            *) echo -e "    ${YELLOW}Skipped${NC}";;
        esac
    else
        cp -r "$SCRIPT_DIR/commands" "$TARGET_DIR/commands"; echo -e "  ${GREEN}+${NC} commands/ (installed)"
    fi
fi

# Agents archive (optional)
if [ -d "$SCRIPT_DIR/agents-bk" ]; then
    echo -e "\n${BLUE}Agent archive (140+ agents):${NC} Install? [y/N]"
    read -p "  > " IBK
    [ "$IBK" = "y" ] || [ "$IBK" = "Y" ] && copy_with_prompt "$SCRIPT_DIR/agents-bk" "$TARGET_DIR/agents-bk" || echo -e "  ${YELLOW}Skipped${NC}"
fi

# Settings
echo -e "\n${BLUE}Settings:${NC}"
for item in "settings.json" "statusline.sh"; do
    [ -f "$SCRIPT_DIR/$item" ] && copy_with_prompt "$SCRIPT_DIR/$item" "$TARGET_DIR/$item"
done
[ -f "$TARGET_DIR/statusline.sh" ] && chmod +x "$TARGET_DIR/statusline.sh"

# CLI Tools (install to ~/.local/bin)
if [ -d "$SCRIPT_DIR/bin" ]; then
    echo -e "\n${BLUE}CLI Tools:${NC}"
    LOCAL_BIN="$HOME/.local/bin"

    # Ensure ~/.local/bin exists and is in PATH
    if [ ! -d "$LOCAL_BIN" ]; then
        echo -e "  ${YELLOW}Creating $LOCAL_BIN${NC}"
        mkdir -p "$LOCAL_BIN"
    fi

    # Check if ~/.local/bin is in PATH
    if [[ ":$PATH:" != *":$LOCAL_BIN:"* ]]; then
        echo -e "  ${YELLOW}!${NC} $LOCAL_BIN is not in your PATH"
        echo "    Add to your shell profile (~/.bashrc or ~/.zshrc):"
        echo "    export PATH=\"\$HOME/.local/bin:\$PATH\""
    fi

    # Install each script from bin/
    for script in "$SCRIPT_DIR/bin/"*; do
        if [ -f "$script" ]; then
            script_name=$(basename "$script")
            dest="$LOCAL_BIN/$script_name"

            if [ -f "$dest" ]; then
                if diff -q "$script" "$dest" >/dev/null 2>&1; then
                    echo -e "  ${GREEN}✓${NC} $script_name (up to date)"
                else
                    echo -e "  ${YELLOW}?${NC} $script_name exists. Overwrite? [y/N]"
                    read -p "    > " OW
                    if [ "$OW" = "y" ] || [ "$OW" = "Y" ]; then
                        cp "$script" "$dest"
                        chmod +x "$dest"
                        echo -e "    ${GREEN}Updated${NC}"
                    else
                        echo -e "    ${YELLOW}Skipped${NC}"
                    fi
                fi
            else
                cp "$script" "$dest"
                chmod +x "$dest"
                echo -e "  ${GREEN}+${NC} $script_name (installed to $LOCAL_BIN)"
            fi
        fi
    done
fi

# Summary
echo -e "\n${GREEN}"
echo "╔════════════════════════════════════════════════╗"
echo "║           Installation Complete!               ║"
echo "╚════════════════════════════════════════════════╝"
echo -e "${NC}"
echo -e "${YELLOW}How it works:${NC}"
echo "  CLAUDE.md references CLAUDE.agents.md"
echo "  Claude reads both files for complete instructions"
echo ""
echo -e "${YELLOW}CLI Tools installed:${NC}"
echo "  git-worktree-workflow - Safe parallel development with worktrees"
echo "    Run 'git-worktree-workflow --help' for usage"
echo -e "\n${GREEN}Happy coding with Claude!${NC}"
