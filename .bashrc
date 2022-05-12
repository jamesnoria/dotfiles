# Enable the subsequent settings only in interactive sessions
case $- in
  *i*) ;;
    *) return;;
esac

# Path to your oh-my-bash installation.
export OSH=/home/jamesnoria/.oh-my-bash

# it'll load a random theme each time that oh-my-bash is loaded.
OSH_THEME="bakke"

OMB_USE_SUDO=true

# Which completions would you like to load? (completions can be found in ~/.oh-my-bash/completions/*)
# Custom completions may be added to ~/.oh-my-bash/custom/completions/
# Example format: completions=(ssh git bundler gem pip pip3)
# Add wisely, as too many completions slow down shell startup.
completions=(
  git
  composer
  ssh
  nvm
)

# Which aliases would you like to load? (aliases can be found in ~/.oh-my-bash/aliases/*)
# Custom aliases may be added to ~/.oh-my-bash/custom/aliases/
# Example format: aliases=(vagrant composer git-avh)
# Add wisely, as too many aliases slow down shell startup.
aliases=(
  general
)

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-bash/plugins/*)
# Custom plugins may be added to ~/.oh-my-bash/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
  git
  bashmarks
  nvm
)

# Which plugins would you like to conditionally load? (plugins can be found in ~/.oh-my-bash/plugins/*)
# Custom plugins may be added to ~/.oh-my-bash/custom/plugins/
# Example format: 
#  if [ "$DISPLAY" ] || [ "$SSH" ]; then
#      plugins+=(tmux-autoattach)
#  fi

source "$OSH"/oh-my-bash.sh

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

# ssh
# export SSH_KEY_PATH="~/.ssh/rsa_id"

# Set personal aliases, overriding those provided by oh-my-bash libs,
# plugins, and themes. Aliases can be placed here, though oh-my-bash
# users are encouraged to define aliases within the OSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias bashconfig="mate ~/.bashrc"
# alias ohmybash="mate ~/.oh-my-bash"

# Use bash-completion, if available
[[ $PS1 && -f /usr/share/bash-completion/bash_completion ]] && \
      . /usr/share/bash-completion/bash_completion



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

cdnvm() {
    command cd "$@";
    nvm_path=$(nvm_find_up .nvmrc | tr -d '\n')

    # If there are no .nvmrc file, use the default nvm version
    if [[ ! $nvm_path = *[^[:space:]]* ]]; then

        declare default_version;
        default_version=$(nvm version default);

        # If there is no default version, set it to `node`
        # This will use the latest version on your machine
        if [[ $default_version == "N/A" ]]; then
            nvm alias default node;
            default_version=$(nvm version default);
        fi

        # If the current version is not the default version, set it to use the default version
        if [[ $(nvm current) != "$default_version" ]]; then
            nvm use default;
        fi

    elif [[ -s $nvm_path/.nvmrc && -r $nvm_path/.nvmrc ]]; then
        declare nvm_version
        nvm_version=$(<"$nvm_path"/.nvmrc)

        declare locally_resolved_nvm_version
        # `nvm ls` will check all locally-available versions
        # If there are multiple matching versions, take the latest one
        # Remove the `->` and `*` characters and spaces
        # `locally_resolved_nvm_version` will be `N/A` if no local versions are found
        locally_resolved_nvm_version=$(nvm ls --no-colors "$nvm_version" | tail -1 | tr -d '\->*' | tr -d '[:space:]')

        # If it is not already installed, install it
        # `nvm install` will implicitly use the newly-installed version
        if [[ "$locally_resolved_nvm_version" == "N/A" ]]; then
            nvm install "$nvm_version";
        elif [[ $(nvm current) != "$locally_resolved_nvm_version" ]]; then
            nvm use "$nvm_version";
        fi
    fi
}
alias cd='cdnvm'
cd "$PWD"

eval "$(starship init bash)"
. "$HOME/.cargo/env"
