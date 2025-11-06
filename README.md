# fzm - Fuzzy Manpager

A beautiful interactive terminal manpage viewer with fuzzy finding capabilities. fzm enhances your manpage browsing experience with intuitive search, rich previews, and seamless integration with other documentation tools.


## ✨ Features

### 🔍 Smart Search & Navigation
- **Fuzzy Finding**: Intuitive search through all available manpages using fzf
- **Multiple Search Modes**: 
  - Fuzzy search with partial matching
  - Exact match with single quotes
  - Multi-term AND search
  - Prefix/suffix matching
  - Exclusion with `!term`
- **Interactive Preview**: Real-time manpage preview with syntax highlighting
- **Toggleable Preview Window**: Show/hide preview pane with `Ctrl-Space` or `Ctrl-P`

### 📖 Enhanced Documentation
- **TLDR Integration**: Combine manpages with practical examples from tldr
- **Syntax Highlighting**: Beautiful code highlighting using bat (when available)
- **Smart Wrapping**: Proper text wrapping in preview panes
- **Section Headers**: Clear visual separation between examples and full documentation

### 🎨 Rich Interface
- **Beautiful Colors**: Custom color scheme with optimal contrast
- **Interactive Controls**:
  - Scroll preview with `Ctrl-D/Ctrl-U` (half page) and `Ctrl-F/Ctrl-B` (full page)
  - Resize preview pane with `Alt-Up/Alt-Down`
  - Toggle text wrapping with `Alt-W`
  - Change sort order with `Ctrl-R`
- **Visual Borders**: Clean, rounded borders and section separators
- **Responsive Layout**: Adapts to terminal size and preferences

### ⚡ Performance & Integration
- **Fast Startup**: Optimized for quick access to documentation
- **Direct Access**: Pass commands directly for instant manpage viewing
- **Seamless Fallbacks**: Graceful degradation when optional tools are missing
- **Alias-Friendly**: Easy to integrate as `man` replacement

## 🚀 Quick Start

### Basic Usage
```bash
# Browse all manpages interactively
fzm

# Open specific command directly
fzm ssh

# Browse with tldr examples
fzm -e

# Open specific command with examples
fzm --example curl
```

### Installation
1. Ensure dependencies are installed:
```bash
# Required
sudo apt install fzf man-db  # Ubuntu/Debian
brew install fzf             # macOS

# Optional (for enhanced experience)
sudo apt install bat tldr    # Ubuntu/Debian
brew install bat tldr        # macOS
```

2. Download the script and make it executable:
```bash
curl -o fzm.sh https://raw.githubusercontent.com/stefan-hacks/fzm/main/fzm.sh
chmod +x fzm.sh
sudo mv fzm.sh /usr/local/bin/fzm
```

### Shell Integration
Add to your `~/.bashrc` or `~/.zshrc`:
```bash
# Replace standard man with fzm
alias man='fzm'

# Quick access to examples
alias mane='fzm -e'

# Keep original man command
alias oman='/usr/bin/man'
```

## ⌨️ Interactive Controls

| Key Binding | Action |
|-------------|--------|
| `Enter` | Open selected manpage |
| `Ctrl-Space` / `Ctrl-P` | Toggle preview window |
| `Ctrl-D` / `Ctrl-U` | Scroll preview down/up (half page) |
| `Ctrl-F` / `Ctrl-B` | Scroll preview down/up (full page) |
| `Alt-Up` / `Alt-Down` | Resize preview pane |
| `Alt-W` | Toggle preview text wrapping |
| `Ctrl-R` | Toggle sort order |
| `Ctrl-A` | Select all items |
| `Esc` | Exit without opening |

## 📚 Search Tips

- **Fuzzy Search**: Just type parts of the command name
- **Exact Match**: Use single quotes: `'command'`
- **Multi-word**: Space-separated terms (AND search)
- **Prefix/Suffix**: `^prefix` or `suffix$`
- **Exclusion**: `!term` to exclude matches

## 🛠️ Dependencies

### Required
- **fzf**: Fuzzy finder ([installation](https://github.com/junegunn/fzf))
- **man**: Manual page viewer (usually pre-installed)

### Optional
- **bat**: Syntax highlighting ([installation](https://github.com/sharkdp/bat))
- **tldr**: Practical examples ([installation](https://github.com/tldr-pages/tldr))

## 🎯 Use Cases

### For Developers
```bash
# Quickly find the right git command
fzm git

# Explore awk with practical examples
fzm -e awk

# Compare similar commands
fzm 'docker' 'podman'
```

### For System Administrators
```bash
# Troubleshoot network issues
fzm -e netstat ss ip

# Manage processes
fzm ps top htop

# File operations
fzm find grep sed
```

### For Learning
```bash
# Discover new commands
fzm

# Learn with examples
fzm -e

# Deep dive into complex tools
fzm tar rsync ssh
```

## 🔧 Advanced Configuration

### Environment Variables
The script respects standard environment variables:
- `MANWIDTH`: Control manpage width
- `MANPAGER`: Custom manpage viewer

### Custom Preview Size
Cycle through preview sizes: 35% → 50% → 65% → 80%

### Color Customization
The script includes a custom color scheme that works with most terminal themes.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit pull requests for:
- Bug fixes
- New features
- Documentation improvements
- Performance optimizations

## 📄 License

This project is open source. Feel free to use and modify as needed.

---

**fzm** - Making manpages beautiful and accessible since 2024. ✨
