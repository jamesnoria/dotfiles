# Terminal Configuration
cp ../.bashrc ../..

# Install basic packages
sudo apt install vim tree curl ranger -y

# Configure Vim
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim