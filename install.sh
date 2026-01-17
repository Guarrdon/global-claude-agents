#!/bin/bash
# ============================================
# Global Claude Agents - Install Script
# ============================================
# This script installs/merges the global Claude
# agents and configuration into your environment.
# ============================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory (where this repo is cloned)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${BLUE}"
echo "╔════════════════════════════════════════════════╗"
echo "║     Global Claude Agents - Installer           ║"
echo "╚════════════════════════════════════════════════╝"
echo -e "${NC}"

# ----- Get target directory -----
DEFAULT_TARGET="$HOME/.claude"
echo -e "${YELLOW}Where is your global Claude configuration directory?${NC}"
echo -e "Press Enter for default: ${GREEN}$DEFAULT_TARGET${NC}"
read -p "> " TARGET_DIR

if [ -z "$TARGET_DIR" ]; then
    TARGET_DIR="$DEFAULT_TARGET"
fi

# Expand ~ if used
TARGET_DIR="${TARGET_DIR/#\~/$HOME}"

echo ""
echo -e "Target directory: ${GREEN}$TARGET_DIR${NC}"

# ----- Check if target exists -----
if [ ! -d "$TARGET_DIR" ]; then
    echo -e "${YELLOW}Target directory does not exist. Create it?${NC} [Y/n]"
    read -p "> " CREATE_DIR
    if [ "$CREATE_DIR" != "n" ] && [ "$CREATE_DIR" != "N" ]; then
        mkdir -p "$TARGET_DIR"
        echo -e "${GREEN}Created $TARGET_DIR${NC}"
    else
        echo -e "${RED}Aborted.${NC}"
        exit 1
    fi
fi

# ----- Backup existing configuration -----
BACKUP_DIR="$TARGET_DIR/backups"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_PATH="$BACKUP_DIR/backup_$TIMESTAMP"

echo ""
echo -e "${BLUE}Creating backup of existing configuration...${NC}"

mkdir -p "$BACKUP_PATH"

# List of files/directories to backup (if they exist)
BACKUP_ITEMS=(
    "CLAUDE.md"
    "settings.json"
    "statusline.sh"
    "agents"
    "agents-bk"
    "AGENT_SELECTION_GUIDE.md"
    "DOCUMENTATION_AGENT_HIERARCHY.md"
    "DOC_MASTER_GUIDE.md"
    "SETUP_SUMMARY.md"
)

BACKED_UP=0
for item in "${BACKUP_ITEMS[@]}"; do
    if [ -e "$TARGET_DIR/$item" ]; then
        cp -r "$TARGET_DIR/$item" "$BACKUP_PATH/"
        BACKED_UP=$((BACKED_UP + 1))
    fi
done

if [ $BACKED_UP -gt 0 ]; then
    echo -e "${GREEN}Backed up $BACKED_UP items to: $BACKUP_PATH${NC}"
else
    echo -e "${YELLOW}No existing configuration found to backup.${NC}"
    rmdir "$BACKUP_PATH" 2>/dev/null || true
fi

# ----- Install/Merge configuration -----
echo ""
echo -e "${BLUE}Installing configuration...${NC}"

# Function to copy with merge prompt
copy_with_prompt() {
    local src="$1"
    local dest="$2"
    local name=$(basename "$src")

    if [ -e "$dest" ]; then
        # Check if files are different
        if [ -f "$src" ] && [ -f "$dest" ]; then
            if diff -q "$src" "$dest" > /dev/null 2>&1; then
                echo -e "  ${GREEN}✓${NC} $name (already up to date)"
                return
            fi
        fi

        echo -e "  ${YELLOW}?${NC} $name exists. Overwrite? [y/N/d(iff)]"
        read -p "    > " OVERWRITE
        case "$OVERWRITE" in
            y|Y)
                if [ -d "$src" ]; then
                    rm -rf "$dest"
                    cp -r "$src" "$dest"
                else
                    cp "$src" "$dest"
                fi
                echo -e "    ${GREEN}Replaced${NC}"
                ;;
            d|D)
                if [ -f "$src" ] && [ -f "$dest" ]; then
                    echo -e "    ${BLUE}--- Differences ---${NC}"
                    diff "$dest" "$src" || true
                    echo -e "    ${BLUE}-------------------${NC}"
                    echo -e "    Overwrite? [y/N]"
                    read -p "    > " OVERWRITE2
                    if [ "$OVERWRITE2" = "y" ] || [ "$OVERWRITE2" = "Y" ]; then
                        cp "$src" "$dest"
                        echo -e "    ${GREEN}Replaced${NC}"
                    else
                        echo -e "    ${YELLOW}Skipped${NC}"
                    fi
                else
                    echo -e "    ${YELLOW}Cannot diff directories. Skipped.${NC}"
                fi
                ;;
            *)
                echo -e "    ${YELLOW}Skipped${NC}"
                ;;
        esac
    else
        if [ -d "$src" ]; then
            cp -r "$src" "$dest"
        else
            cp "$src" "$dest"
        fi
        echo -e "  ${GREEN}+${NC} $name (installed)"
    fi
}

# Copy documentation files
echo ""
echo -e "${BLUE}Documentation files:${NC}"
for doc in "CLAUDE.md" "AGENT_SELECTION_GUIDE.md" "DOCUMENTATION_AGENT_HIERARCHY.md" "DOC_MASTER_GUIDE.md" "SETUP_SUMMARY.md"; do
    if [ -f "$SCRIPT_DIR/$doc" ]; then
        copy_with_prompt "$SCRIPT_DIR/$doc" "$TARGET_DIR/$doc"
    fi
done

# Copy agents directory
echo ""
echo -e "${BLUE}Agents:${NC}"
if [ -d "$SCRIPT_DIR/agents" ]; then
    if [ -d "$TARGET_DIR/agents" ]; then
        echo -e "  ${YELLOW}?${NC} agents/ directory exists."
        echo "    Options: [m]erge, [r]eplace, [s]kip"
        read -p "    > " AGENT_ACTION
        case "$AGENT_ACTION" in
            m|M)
                echo -e "    ${BLUE}Merging agents...${NC}"
                cp -rn "$SCRIPT_DIR/agents/"* "$TARGET_DIR/agents/" 2>/dev/null || true
                # Also copy subdirectories
                for subdir in "$SCRIPT_DIR/agents/"*/; do
                    if [ -d "$subdir" ]; then
                        subname=$(basename "$subdir")
                        mkdir -p "$TARGET_DIR/agents/$subname"
                        cp -rn "$subdir"* "$TARGET_DIR/agents/$subname/" 2>/dev/null || true
                    fi
                done
                echo -e "    ${GREEN}Merged (new files added, existing preserved)${NC}"
                ;;
            r|R)
                rm -rf "$TARGET_DIR/agents"
                cp -r "$SCRIPT_DIR/agents" "$TARGET_DIR/agents"
                echo -e "    ${GREEN}Replaced${NC}"
                ;;
            *)
                echo -e "    ${YELLOW}Skipped${NC}"
                ;;
        esac
    else
        cp -r "$SCRIPT_DIR/agents" "$TARGET_DIR/agents"
        echo -e "  ${GREEN}+${NC} agents/ (installed)"
    fi
fi

# Copy agents-bk directory (optional archive)
if [ -d "$SCRIPT_DIR/agents-bk" ]; then
    echo ""
    echo -e "${BLUE}Agent archive (agents-bk):${NC}"
    echo "  This contains archived/reference agents. Install? [y/N]"
    read -p "  > " INSTALL_BK
    if [ "$INSTALL_BK" = "y" ] || [ "$INSTALL_BK" = "Y" ]; then
        copy_with_prompt "$SCRIPT_DIR/agents-bk" "$TARGET_DIR/agents-bk"
    else
        echo -e "  ${YELLOW}Skipped${NC}"
    fi
fi

# Copy settings and scripts
echo ""
echo -e "${BLUE}Settings and scripts:${NC}"
for item in "settings.json" "statusline.sh"; do
    if [ -f "$SCRIPT_DIR/$item" ]; then
        copy_with_prompt "$SCRIPT_DIR/$item" "$TARGET_DIR/$item"
    fi
done

# Make statusline.sh executable
if [ -f "$TARGET_DIR/statusline.sh" ]; then
    chmod +x "$TARGET_DIR/statusline.sh"
fi

# ----- Summary -----
echo ""
echo -e "${GREEN}"
echo "╔════════════════════════════════════════════════╗"
echo "║           Installation Complete!               ║"
echo "╚════════════════════════════════════════════════╝"
echo -e "${NC}"

if [ $BACKED_UP -gt 0 ]; then
    echo -e "Backup saved to: ${BLUE}$BACKUP_PATH${NC}"
fi

echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "  1. Review CLAUDE.md for global instructions"
echo "  2. Check agents/ directory for available agents"
echo "  3. Customize settings.json as needed"
echo ""
echo -e "${GREEN}Happy coding with Claude!${NC}"
