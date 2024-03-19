#/bin/sh

echo "Running setup script..."
echo $0
full_path=$(realpath $0)
echo $full_path
dir_path=$(dirname $full_path)
echo $dir_path


# update package management
sudo apt update

# install zsh
if [ "$ZSH_VERSION" == "" ]
then
    sudo apt install -y zsh
    sudo chsh -s /usr/bin/zsh
fi

# install oh-my-zsh
rm -rf ~/.oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh) --unattended --keep-zshrc"

# use LF for clones repos
git config --global core.autocrlf input                                                                                                                                                                               ─╯
git config --global core.autocrlf false

#install Nerd Fonts
git clone --depth 1 https://github.com/ryanoasis/nerd-fonts.git ~/nerdfonts
~/nerdfonts/isntall.sh

# install powerlevel10k
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k
cp $dir_path/.p10k.zsh ~/.p10k.zsh

# zsh-autosuggestions
rm -rf  ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# zsh-syntax-highlighting
rm -rf ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

#install ohmyposh
# sudo wget https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-linux-amd64 -O /usr/local/bin/oh-my-posh
# sudo chmod +x /usr/local/bin/oh-my-posh

#install useful tools
sudo add-apt-repository -y ppa:bashtop-monitor/bashtop

sudo apt update
sudo apt install -y bashtop

#update .zshrc

echo "
source $dir_path/user.rc
" >> ~/.zshrc

zsh -lic 'sudo curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.37.2/install.sh | zsh && source ~/.zshrc && nvm install node && nvm install 14 && echo "setup complete"'

cp $dir_path/.gitconfig ~
