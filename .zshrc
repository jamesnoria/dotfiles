# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="spaceship"

# Add wisely, as too many plugins slow down shell startup.
plugins=(
  git 
  zsh-autosuggestions
)

source $ZSH/oh-my-zsh.sh

# User configuration

# --- ALIASES ---

# GIT
alias g="git"
alias gtree="git --no-pager log --pretty='%Cred%h%Creset | %C(yellow)%d%Creset %s %Cgreen(%cr)%Creset %C(cyan)[%an]%Creset' --graph --all"
alias gmain="git branch -m master main"
alias gfix="git pull origin main --allow-unrelated-histories" # fix pull conflicts with remote repositories
alias gac="git add . && git commit -m"
alias gcl="git clone"
alias gp="git push origin ${current_branch}"
alias gpl="git pull origin ${current_branch}"
alias gs="git status -s"
alias gadd="git remote add origin main"

# OS
alias ram="free -h"
alias peso="du -sh"
alias off="shutdown -P now"
alias ins="bash ~/dotfiles/automations/install.sh"
alias dot="bash ~/dotfiles/automations/dotfiles.sh"
alias up="sudo apt update -y && sudo apt upgrade -y && sudo apt autoremove -y"
alias rmf="sudo rm -r"

# SHELL
alias ll="exa --header --long --icons -a"
alias ls="exa --icons"
alias tree="exa --tree --header --icons --long"
alias t="touch"
alias cl='clear'
alias james='vim ~/.bashrc'
alias e="exit"
alias cat="batcat"
alias r="ranger"
alias act="source ~/.bashrc"
alias ff="find . -name" #find a regular file (f), do not forget: "[file type]"
alias fd="find . -type d -name" #find a directory (d)
alias x="xclip -sel c <"
alias tx="tmux attach-session -t"
alias stt="subl ."
alias 1p="x ~/.notTrusted"

# PYTHON
alias a="source env/bin/activate"
alias d="deactivate"
alias ve="python3 -m venv env && source env/bin/activate"
alias jup="jupyter notebook"
alias p="python3"
alias req="touch requirements.txt && pip freeze > requirements.txt"
alias pi="pip install"

# DJANGO
alias rs="python3 manage.py runserver"
alias mgr="python3 manage.py makemigrations && python3 manage.py migrate && python3 manage.py runserver"
alias deploy="bash ~/dotfiles/automations/deploy_heroku.sh" #argument: commit message

# PERSONAL SHORTCUTS
alias web="ping www.google.com"
alias dow="cd ~/Downloads"
alias gl="pass -c Programming/gitlab.com"
alias gh="pass -c Programming/github.com"
alias pm="pass -c Personal/pm.me"
alias mx="~/Downloads/marktext-x86_64.AppImage"

# DATABASES
alias mysql="mysql -u root -h localhost -p"
alias psql="sudo -u postgres psql"
alias pgadmin4="source ~/pgadmin4/bin/activate && pgadmin4"
alias mongo-start="sudo systemctl start mongod"
alias mongo-status="sudo systemctl status mongod"
alias mongo-stop="sudo systemctl stop mongod"

# DOCKER
alias dclean="sudo docker system prune"

# C++
alias c="bash ~/dotfiles/automations/cpp.sh"

# FRONT-END STUFF
alias live="live-server"
alias f="prettier -w" #format html, css, scss and js files
alias lintwf="bash ~/dotfiles/automations/linter_conf.sh"

# BACK-END STUFF
alias doppler-env="doppler secrets download --no-file --format env > .env"

# PNPM
alias pr="pnpm run"
alias pid="pnpm install -D"
alias pi="pnpm install"

# NVM
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm

# place this after nvm initialization!
autoload -U add-zsh-hook
load-nvmrc() {
  local node_version="$(nvm version)"
  local nvmrc_path="$(nvm_find_nvmrc)"

  if [ -n "$nvmrc_path" ]; then
    local nvmrc_node_version=$(nvm version "$(cat "${nvmrc_path}")")

    if [ "$nvmrc_node_version" = "N/A" ]; then
      nvm install
    elif [ "$nvmrc_node_version" != "$node_version" ]; then
      nvm use
    fi
  elif [ "$node_version" != "$(nvm version default)" ]; then
    echo "Reverting to nvm default version"
    nvm use default
  fi
}
add-zsh-hook chpwd load-nvmrc
load-nvmrc