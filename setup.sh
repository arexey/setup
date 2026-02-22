#/bin/sh

echo "Running setup script..."
echo $0
full_path=$(realpath $0)
echo $full_path
dir_path=$(dirname $full_path)
echo $dir_path

# install Homebrew
if command -v brew >/dev/null 2>&1; then
    echo "brew is installed"
else
    echo "brew is not installed"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" < /dev/null
    echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv zsh)"' >> /home/user/.zshrc
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv zsh)"
fi

brew install figlet lolcat

# update package management
if [[ -f /etc/debian_version ]]; then
    sudo apt update
    sudo apt upgrade -y
    sudo apt install -y curl wget git
fi

# copy .gitconfig
figlet -t -f slant "=== copy .gitgonfig ===" | lolcat
cp $dir_path/.gitconfig ~

figlet -t -f slant "=== install zsh ===" | lolcat
if [ "$ZSH_VERSION" == "" ]; then
    brew install zsh
    # sudo apt install -y zsh
    sudo chsh -s /usr/bin/zsh
fi

# install oh-my-zsh
figlet -t -f slant "=== install oh-my-zsh ===" | lolcat

rm -rf ~/.oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh) --unattended --keep-zshrc"

# use LF for clones repos
git config --global core.autocrlf input
git config --global core.autocrlf false

# install Nerd Fonts
figlet -t -f slant "=== install Nerd Fonts ===" | lolcat
git clone --depth 1 https://github.com/ryanoasis/nerd-fonts.git ~/nerdfonts
~/nerdfonts/isntall.sh

# install powerlevel10k
figlet -t -f slant "=== install powerlevel10k ===" | lolcat
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k
cp $dir_path/.p10k.zsh ~/.p10k.zsh

# zsh-autosuggestions
figlet -t -f slant "=== install zsh-autosuggestions ===" | lolcat
rm -rf  ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# zsh-syntax-highlighting
figlet -t -f slant "=== install zsh-syntax-highlighting ===" | lolcat
rm -rf ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# install cli tools
figlet -t -f slant "=== install CLI tools ===" | lolcat
figlet -t -f slant "=== install fzf ===" | lolcat
brew install fzf
figlet -t -f slant "=== install fzf-git ===" | lolcat
git clone https://github.com/junegunn/fzf-git.sh.git ~/.fzf-git
figlet -t -f slant "=== install bat ===" | lolcat
brew install bat
figlet -t -f slant "=== install fd ===" | lolcat
brew install fd
figlet -t -f slant "=== install git-delta ===" | lolcat
brew install git-delta
echo "
[core]
    pager = delta

[interactive]
    diffFilter = delta --color-only

[delta]
    navigate = true    # use n and N to move between diff sections
    side-by-side = true


    # delta detects terminal colors automatically; set one of these to disable auto-detection
    # dark = true
    # light = true

[merge]
    conflictstyle = diff3

[diff]
    colorMoved = default
" >> ~/.gitconfig
figlet -t -f slant "=== install eza ===" | lolcat
brew install eza
figlet -t -f slant "=== install zoxide ===" | lolcat
brew install zoxide
figlet -t -f slant "=== install tldr ===" | lolcat
brew install tlrc
figlet -t -f slab "=== install thefuck ===" | lolcat
brew install thefuck


#install ohmyposh
# sudo wget https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-linux-amd64 -O /usr/local/bin/oh-my-posh
# sudo chmod +x /usr/local/bin/oh-my-posh

#install useful tools
figlet -f slant "=== install usefult ools ===" | lolcat
figlet -f slant "=== install python3 ===" | lolcat
brew install python3
python3 -m pip install psutil
brew install bash coreutils gnu-sed git
if [ "$OSTYPE" == "darwin"* ]; then
    brew install osx-cpu-temp
    git clone https://github.com/aristocratos/bashtop.git
    cd bashtop
    sudo make install
else
    sudo add-apt-repository -y ppa:bashtop-monitor/bashtop
    sudo apt update
    sudo apt install -y bashtop
fi

#update .zshrc
figlet -f slant "=== update .zshrc ===" | lolcat
sed -i '.bak' '/user.rc/d' ~/.zshrc
echo "source $dir_path/user.rc" >> ~/.zshrc

figlet -f slant "=== install nvm ===" | lolcat
zsh -lic 'sudo curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.37.2/install.sh | zsh && source ~/.zshrc && nvm install node && nvm install 14 && echo "setup complete"'

