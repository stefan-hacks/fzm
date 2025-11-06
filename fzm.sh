#!/usr/bin/env bash

# fzm - Fuzzy Manpager
# A beautiful interactive terminal manpage viewer with fuzzy finding
# Dependencies: fzf, man, bat (optional), tldr (optional)

set -euo pipefail

# Color definitions
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly MAGENTA='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly BOLD='\033[1m'
readonly DIM='\033[2m'
readonly RESET='\033[0m'

# Global flags
SHOW_EXAMPLES=0

# Check dependencies
check_dependencies() {
  local missing_deps=()

  for cmd in fzf man; do
    if ! command -v "$cmd" &>/dev/null; then
      missing_deps+=("$cmd")
    fi
  done

  if [[ ${#missing_deps[@]} -gt 0 ]]; then
    echo -e "${RED}Error: Missing required dependencies:${RESET} ${missing_deps[*]}" >&2
    echo -e "${YELLOW}Install with:${RESET}" >&2
    echo "  - fzf: https://github.com/junegunn/fzf" >&2
    exit 1
  fi

  # Check if bat is available for enhanced preview
  if command -v bat &>/dev/null; then
    HAS_BAT=1
  else
    HAS_BAT=0
  fi

  # Check if tldr is available
  if command -v tldr &>/dev/null; then
    HAS_TLDR=1
  else
    HAS_TLDR=0
  fi
}

# Display help
show_help() {
  echo -e "${BOLD}${CYAN}fzm - Fuzzy Manpager${RESET}"
  echo
  echo -e "${BOLD}USAGE:${RESET}"
  echo -e "    ${GREEN}fzm${RESET} [OPTIONS] [COMMAND]"
  echo
  echo -e "${BOLD}OPTIONS:${RESET}"
  echo -e "    ${YELLOW}-e, --example, -eg${RESET}    Show tldr examples with manpages"
  echo -e "    ${YELLOW}-h, --help${RESET}            Show this help message"
  echo
  echo -e "${BOLD}INTERACTIVE KEYS:${RESET}"
  echo -e "    ${GREEN}Enter${RESET}              Open selected manpage in full viewer"
  echo -e "    ${GREEN}Ctrl-Space / Ctrl-P${RESET}  Toggle preview window"
  echo -e "    ${GREEN}Ctrl-D / Ctrl-U${RESET}    Scroll preview down/up (half page)"
  echo -e "    ${GREEN}Ctrl-F / Ctrl-B${RESET}    Scroll preview down/up (full page)"
  echo -e "    ${GREEN}Alt-Up / Alt-Down${RESET}  Resize preview pane up/down"
  echo -e "    ${GREEN}Alt-W${RESET}              Toggle preview wrap"
  echo -e "    ${GREEN}Ctrl-R${RESET}             Toggle sort order"
  echo -e "    ${GREEN}Ctrl-A${RESET}             Select all"
  echo -e "    ${GREEN}Esc${RESET}                Exit without opening"
  echo
  echo -e "${BOLD}PREVIEW PANE:${RESET}"
  echo -e "    ${DIM}• Starts hidden - toggle with Ctrl-Space${RESET}"
  echo -e "    ${DIM}• Resize with Alt-Up/Down${RESET}"
  echo -e "    ${DIM}• Cycle sizes: 50% → 65% → 80% → 35% → 50%${RESET}"
  echo
  echo -e "${BOLD}SEARCH TIPS:${RESET}"
  echo -e "    ${DIM}• Fuzzy search: just type parts of the command name${RESET}"
  echo -e "    ${DIM}• Exact match: 'command (use single quotes)${RESET}"
  echo -e "    ${DIM}• Multi-word: space-separated terms (AND search)${RESET}"
  echo -e "    ${DIM}• Prefix: ^prefix to match start${RESET}"
  echo -e "    ${DIM}• Suffix: suffix\$ to match end${RESET}"
  echo -e "    ${DIM}• Negate: !term to exclude${RESET}"
  echo
  echo -e "${BOLD}EXAMPLES:${RESET}"
  echo -e "    ${CYAN}fzm${RESET}                     Browse all manpages"
  echo -e "    ${CYAN}fzm -e${RESET}                  Browse with tldr examples"
  echo -e "    ${CYAN}fzm -h${RESET}                  Show this help"
  echo
  echo -e "${BOLD}ALIAS SETUP:${RESET}"
  echo -e "    ${DIM}# Add to ~/.bashrc or ~/.zshrc:${RESET}"
  echo -e "    ${GREEN}alias man='fzm'${RESET}"
  echo -e "    ${GREEN}alias mane='fzm -e'${RESET}  ${DIM}# with examples${RESET}"
  echo
  echo -e "${BOLD}DEPENDENCIES:${RESET}"
  echo -e "    ${GREEN}✓${RESET} fzf, man"
  echo -e "    ${YELLOW}○${RESET} bat (optional, for syntax highlighting)"
  echo -e "    ${YELLOW}○${RESET} tldr (optional, for examples with -e flag)"
  echo
}

# Enhanced preview command with tldr at top and proper text wrapping
build_preview_command() {
  local width
  width="${FZF_PREVIEW_COLUMNS:-80}"

  if [[ $SHOW_EXAMPLES -eq 1 ]] && [[ $HAS_TLDR -eq 1 ]]; then
    if [[ $HAS_BAT -eq 1 ]]; then
      cat <<'EOF'
cmd=$(echo {1} | sed "s/[[:space:]]*$//"); 
sect=$(echo {2} | tr -d "()"); 
tldr_out=$(tldr "$cmd" 2>/dev/null); 
man_out=$(MANWIDTH='"$width"' man "$sect" "$cmd" 2>/dev/null | col -bx); 
if [ -n "$tldr_out" ] || [ -n "$man_out" ]; then 
    echo "╔═══════════════════════════════════════════════════════════════╗"; 
    echo "║                       TLDR EXAMPLES                          ║"; 
    echo "╚═══════════════════════════════════════════════════════════════╝"; 
    if [ -n "$tldr_out" ]; then 
        echo "$tldr_out" | bat --style=plain --color=always --language=md --paging=never --wrap=character 2>/dev/null; 
    else 
        echo "No tldr examples available"; 
    fi; 
    echo ""; 
    echo "╔═══════════════════════════════════════════════════════════════╗"; 
    echo "║                         MANPAGE                              ║"; 
    echo "╚═══════════════════════════════════════════════════════════════╝"; 
    if [ -n "$man_out" ]; then 
        echo "$man_out" | bat --style=plain --color=always --language=man --paging=never --wrap=character 2>/dev/null; 
    else 
        echo "Manpage preview unavailable"; 
    fi; 
else 
    echo "Preview unavailable for command: $cmd"; 
fi
EOF
    else
      cat <<'EOF'
cmd=$(echo {1} | sed "s/[[:space:]]*$//"); 
sect=$(echo {2} | tr -d "()"); 
tldr_out=$(tldr "$cmd" 2>/dev/null); 
man_out=$(MANWIDTH='"$width"' MANPAGER=cat man "$sect" "$cmd" 2>/dev/null); 
if [ -n "$tldr_out" ] || [ -n "$man_out" ]; then 
    echo "╔═══════════════════════════════════════════════════════════════╗"; 
    echo "║                       TLDR EXAMPLES                          ║"; 
    echo "╚═══════════════════════════════════════════════════════════════╝"; 
    if [ -n "$tldr_out" ]; then 
        echo "$tldr_out"; 
    else 
        echo "No tldr examples available"; 
    fi; 
    echo ""; 
    echo "╔═══════════════════════════════════════════════════════════════╗"; 
    echo "║                         MANPAGE                              ║"; 
    echo "╚═══════════════════════════════════════════════════════════════╝"; 
    if [ -n "$man_out" ]; then 
        echo "$man_out"; 
    else 
        echo "Manpage preview unavailable"; 
    fi; 
else 
    echo "Preview unavailable for command: $cmd"; 
fi
EOF
    fi
  else
    if [[ $HAS_BAT -eq 1 ]]; then
      echo 'cmd=$(echo {1} | sed "s/[[:space:]]*$//"); sect=$(echo {2} | tr -d "()"); MANWIDTH='"$width"' man "$sect" "$cmd" 2>/dev/null | col -bx | bat --style=plain --color=always --language=man --paging=never --wrap=character 2>/dev/null || echo "Preview unavailable"'
    else
      echo 'cmd=$(echo {1} | sed "s/[[:space:]]*$//"); sect=$(echo {2} | tr -d "()"); MANWIDTH='"$width"' MANPAGER=cat man "$sect" "$cmd" 2>/dev/null || echo "Preview unavailable"'
    fi
  fi
}

# Main function
main() {
  # Parse arguments
  local target_cmd=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
    -h | --help)
      show_help
      exit 0
      ;;
    -e | -eg | --example | --examples)
      SHOW_EXAMPLES=1
      shift
      ;;
    -*)
      echo -e "${RED}Unknown option: $1${RESET}" >&2
      echo -e "Use ${YELLOW}fzm --help${RESET} for usage information" >&2
      exit 1
      ;;
    *)
      target_cmd="$1"
      shift
      ;;
    esac
  done

  # Check dependencies
  check_dependencies

  # Warn if examples requested but tldr not available
  if [[ $SHOW_EXAMPLES -eq 1 ]] && [[ $HAS_TLDR -eq 0 ]]; then
    echo -e "${YELLOW}Warning: tldr not found. Install it for examples support.${RESET}" >&2
    echo -e "${DIM}  https://github.com/tldr-pages/tldr${RESET}" >&2
    SHOW_EXAMPLES=0
    sleep 2
  fi

  # If specific command provided, try to open it directly
  if [[ -n "$target_cmd" ]]; then
    if man -w "$target_cmd" &>/dev/null 2>&1; then
      if [[ $SHOW_EXAMPLES -eq 1 ]] && [[ $HAS_TLDR -eq 1 ]]; then
        echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════╗${RESET}"
        echo -e "${CYAN}║                       TLDR EXAMPLES                          ║${RESET}"
        echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════╝${RESET}"
        tldr "$target_cmd" 2>/dev/null || echo -e "${DIM}No tldr examples available for $target_cmd${RESET}"
        echo -e "\n${CYAN}╔═══════════════════════════════════════════════════════════════╗${RESET}"
        echo -e "${CYAN}║                         MANPAGE                              ║${RESET}"
        echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════╝${RESET}"
        man "$target_cmd"
      else
        exec man "$target_cmd"
      fi
      exit 0
    else
      echo -e "${YELLOW}Command '$target_cmd' not found. Opening fuzzy search...${RESET}" >&2
      sleep 1
    fi
  fi

  # Create FZF header with keyboard shortcuts
  local header
  if [[ $SHOW_EXAMPLES -eq 1 ]]; then
    header='╔════════════════════════════════════════════════════════════════════════════╗
║  🔍 FZM + TLDR  • Ctrl-Space: preview • Alt-↑/↓: resize • Ctrl-D/U: scroll ║
╚════════════════════════════════════════════════════════════════════════════╝'
  else
    header='╔════════════════════════════════════════════════════════════════════════════╗
║  🔍 FZM - Fuzzy Manpager  • Ctrl-Space: preview • Alt-↑/↓: resize • Ctrl-D/U ║
╚════════════════════════════════════════════════════════════════════════════╝'
  fi

  # Build preview command
  local preview_cmd
  preview_cmd=$(build_preview_command)

  # Get manpages and launch fzf with enhanced features
  local selection
  selection=$(man -k . 2>/dev/null |
    fzf --ansi \
      --height=100% \
      --layout=reverse \
      --border=rounded \
      --info=inline \
      --prompt="📖 Search manpages > " \
      --pointer="▶" \
      --marker="✓" \
      --header="$header" \
      --header-lines=0 \
      --preview="$preview_cmd" \
      --preview-window='right:50%:border-left:hidden:wrap:nohidden' \
      --bind='ctrl-space:toggle-preview' \
      --bind='ctrl-p:toggle-preview' \
      --bind='ctrl-d:preview-down' \
      --bind='ctrl-u:preview-up' \
      --bind='ctrl-f:preview-page-down' \
      --bind='ctrl-b:preview-page-up' \
      --bind='alt-up:change-preview-window(65%|80%|35%|50%)' \
      --bind='alt-down:change-preview-window(35%|50%|65%|80%)' \
      --bind='alt-w:toggle-preview-wrap' \
      --bind='ctrl-r:toggle-sort' \
      --bind='ctrl-a:select-all' \
      --bind='ctrl-e:preview-top' \
      --bind='ctrl-n:preview-bottom' \
      --bind='shift-up:preview-half-page-up' \
      --bind='shift-down:preview-half-page-down' \
      --color='fg:#d0d0d0,bg:#1e1e1e,hl:#5f87af' \
      --color='fg+:#ffffff,bg+:#262626,hl+:#5fd7ff' \
      --color='info:#afaf87,prompt:#d7005f,pointer:#af5fff' \
      --color='marker:#87ff00,spinner:#af5fff,header:#87afaf' \
      --color='border:#585858,preview-bg:#1c1c1c' \
      --preview-label='[ Manpage Preview - Ctrl-Space to toggle ]' \
      --preview-label-pos=2 \
      --no-multi \
      --cycle \
      --scroll-off=3)

  # Open selected manpage if any
  if [[ -n "$selection" ]]; then
    # Parse the selection
    local cmd section
    cmd=$(echo "$selection" | awk '{print $1}')
    section=$(echo "$selection" | awk '{print $2}' | tr -d '()')

    echo -e "${GREEN}Opening manpage for:${RESET} ${BOLD}$cmd($section)${RESET}"

    # Show manpage with optional examples
    if [[ $SHOW_EXAMPLES -eq 1 ]] && [[ $HAS_TLDR -eq 1 ]]; then
      echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════╗${RESET}"
      echo -e "${CYAN}║                       TLDR EXAMPLES                          ║${RESET}"
      echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════╝${RESET}"
      tldr "$cmd" 2>/dev/null || echo -e "${DIM}No tldr examples available for $cmd${RESET}"
      echo -e "\n${CYAN}╔═══════════════════════════════════════════════════════════════╗${RESET}"
      echo -e "${CYAN}║                         MANPAGE                              ║${RESET}"
      echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════╝${RESET}"
      man "$section" "$cmd"
    else
      exec man "$section" "$cmd"
    fi
  fi
}

# Run main function
main "$@"
