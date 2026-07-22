#!/usr/bin/env bash
set -euo pipefail

echo "Running setup script..."

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
dir_path="$SCRIPT_DIR"
echo "$dir_path"

detect_platform() {
    case "$(uname -s)" in
        Darwin) PLATFORM=mac;   BREW_PREFIX=/opt/homebrew;            HAS_APT=0 ;;
        Linux)  PLATFORM=linux; BREW_PREFIX=/home/linuxbrew/.linuxbrew
                [[ -f /etc/debian_version ]] && HAS_APT=1 || HAS_APT=0 ;;
        *)      echo "Unsupported platform: $(uname -s)" >&2; exit 1 ;;
    esac
}
detect_platform

load_brew_env() {
    if [[ -x "$BREW_PREFIX/bin/brew" ]]; then
        eval "$("$BREW_PREFIX/bin/brew" shellenv)"
    elif command -v brew >/dev/null 2>&1; then
        eval "$(brew shellenv)"
    fi
}

clone_if_missing() {
    local repo=$1 dest=$2; shift 2
    [[ -d "$dest/.git" ]] || git clone "$@" "$repo" "$dest"
}

# install Homebrew
if ! command -v brew >/dev/null 2>&1; then
    if [[ "$HAS_APT" -eq 1 ]]; then
        sudo apt update
        sudo apt install -y curl git build-essential procps file
    fi
    NONINTERACTIVE=1 /bin/bash -c \
        "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" </dev/null
fi
load_brew_env

brew install figlet lolcat

figlet -t -f slant "=== install zsh ===" | lolcat
if ! command -v zsh >/dev/null 2>&1; then
    brew install zsh
fi
ZSH_BIN="$(command -v zsh)"
if [[ "${SHELL:-}" != "$ZSH_BIN" ]]; then
    grep -qx "$ZSH_BIN" /etc/shells 2>/dev/null || echo "$ZSH_BIN" | sudo tee -a /etc/shells >/dev/null
    chsh -s "$ZSH_BIN" 2>/dev/null || sudo chsh -s "$ZSH_BIN" "$USER"
fi

# install oh-my-zsh
figlet -t -f slant "=== install oh-my-zsh ===" | lolcat
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" \
        "" --unattended --keep-zshrc
fi

# use LF for cloned repos
git config --global core.autocrlf input

# install Nerd Fonts
figlet -t -f slant "=== install Nerd Fonts ===" | lolcat
clone_if_missing https://github.com/ryanoasis/nerd-fonts.git "$HOME/nerdfonts" --depth 1
if [[ ! -f "$HOME/.nerdfonts-installed" ]]; then
    "$HOME/nerdfonts/install.sh" Meslo
    touch "$HOME/.nerdfonts-installed"
fi

# install powerlevel10k
figlet -t -f slant "=== install powerlevel10k ===" | lolcat
clone_if_missing https://github.com/romkatv/powerlevel10k.git "$HOME/powerlevel10k" --depth=1
cp "$dir_path/.p10k.zsh" ~/.p10k.zsh

ZSH_CUSTOM_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

# zsh-autosuggestions
figlet -t -f slant "=== install zsh-autosuggestions ===" | lolcat
clone_if_missing https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM_DIR/plugins/zsh-autosuggestions"

# zsh-syntax-highlighting
figlet -t -f slant "=== install zsh-syntax-highlighting ===" | lolcat
clone_if_missing https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM_DIR/plugins/zsh-syntax-highlighting"

# install cli tools
figlet -t -f slant "=== install CLI tools ===" | lolcat
figlet -t -f slant "=== install fzf ===" | lolcat
brew install fzf
figlet -t -f slant "=== install fzf-git ===" | lolcat
clone_if_missing https://github.com/junegunn/fzf-git.sh.git "$HOME/.fzf-git"
figlet -t -f slant "=== install bat ===" | lolcat
brew install bat
figlet -t -f slant "=== install fd ===" | lolcat
brew install fd
figlet -t -f slant "=== install git-delta ===" | lolcat
brew install git-delta
if ! grep -q '^\s*pager\s*=\s*delta' ~/.gitconfig; then
    cat >> ~/.gitconfig <<'EOF'

[core]
    pager = delta

[interactive]
    diffFilter = delta --color-only

[delta]
    navigate = true
    side-by-side = true

[merge]
    conflictstyle = diff3

[diff]
    colorMoved = default
EOF
fi
figlet -t -f slant "=== install eza ===" | lolcat
brew install eza
figlet -t -f slant "=== install zoxide ===" | lolcat
brew install zoxide
figlet -t -f slant "=== install tldr ===" | lolcat
brew install tlrc
figlet -t -f slab "=== install thefuck ===" | lolcat
if ! command -v thefuck >/dev/null 2>&1; then
    brew install pipx
    pipx ensurepath
    pipx install thefuck || pip3 install --user thefuck
fi

# install useful tools
figlet -f slant "=== install useful tools ===" | lolcat
figlet -f slant "=== install python3 ===" | lolcat
brew install python3
python3 -m pip install --user psutil || pipx install psutil || true
brew install bash coreutils gnu-sed git

brew install bashtop
if [[ "$PLATFORM" == "mac" ]]; then
    brew install osx-cpu-temp
fi

# update .zshrc
figlet -f slant "=== update .zshrc ===" | lolcat
if [[ -f ~/.zshrc ]]; then
    tmp=$(mktemp)
    sed '/shell\.rc/d' ~/.zshrc > "$tmp" && mv "$tmp" ~/.zshrc
fi
echo "source $dir_path/shell.rc" >> ~/.zshrc

figlet -f slant "=== install nvm ===" | lolcat
export NVM_DIR="$HOME/.nvm"
if [[ ! -s "$NVM_DIR/nvm.sh" ]]; then
    curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
fi
# shellcheck disable=SC1091
\. "$NVM_DIR/nvm.sh"
nvm install node
nvm install 14
echo "setup complete"
