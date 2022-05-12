# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="spaceship"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
  git 
  zsh-autosuggestions
)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

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
alias ll="lsd -alh"
alias ls="lsd -1"
alias t="touch"
alias cl='clear'
alias james='vim ~/.zshrc'
alias e="exit"
alias cat="batcat"
alias r="ranger"
alias act="source ~/.zshrc"
alias ff="find . -name" #find a regular file (f), do not forget: "[file type]"
alias fd="find . -type d -name" #find a directory (d)
alias x="xclip -sel c <"
alias tx="tmux attach-session -t"
alias stt="subl ."
alias 1p="x .notTrusted"

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

# Node Version Manager
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
[[ -s "$HOME/.avn/bin/avn.sh" ]] && source "$HOME/.avn/bin/avn.sh" # load avn

autoload -U add-zsh-hook

load-nvmrc() {

  if [[ -f .nvmrc && -r .nvmrc ]]; then

    nvm use

  elif [[ $(nvm version) != $(nvm version default)  ]]; then

    echo "Reverting to nvm default version"

    nvm use default

  fi

}

add-zsh-hook chpwd load-nvmrc

load-nvmrc
