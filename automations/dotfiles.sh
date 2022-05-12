#!/bin/bash
# Program to update my dotfiles (some of them) with my github repository

cd

cp ~/.zshrc dotfiles/
cp ~/.bashrc dotfiles/
cp ~/.vimrc dotfiles/
cp ~/.gitconfig dotfiles/
cp .config/alacritty/alacritty.yml dotfiles/
cp .tmux.conf dotfiles/

cd dotfiles/

git add .
git commit -m "$(date +%D-%T)" # -> storing the current date as the commit message
git push origin main
