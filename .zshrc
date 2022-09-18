# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="spaceship"

plugins=(
	git
	zsh-autosuggestions
)

source $ZSH/oh-my-zsh.sh

# === SPACESHIP CONFIG ===
SPACESHIP_PACKAGE_SHOW=false

# === NVM ===

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

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

# === AWS ===

aisp() {
  unset _PROFILE;
  # creates tmp file
  tf=$(mktemp /tmp/aisp.XXXXXXXXX)
  # runs aws-switch-profiles and stores user selection to tmp file
  aws-switch-profiles $tf
  # reads in tmp file and stores to variable
  _PROFILE=$(<$tf);
  if [ -z $_PROFILE ];
    then
      echo "AWS_PROFILE not selected.";
    else
      export AWS_PROFILE=$_PROFILE
  fi

  rm $tf;
}

# === ALIASES ===

alias cl="clear"
alias logs="git log --pretty='%Cred%h%Creset | %C(yellow)%d%Creset %s %Cgreen(%cr)%Creset %C(cyan)[%an]%Creset' --graph --all"
alias gs="git status -s"
alias up="sudo apt update -y && sudo apt upgrade -y && sudo apt autoremove -y"
alias cat="batcat"
alias c="bash ~/.config/cpp.sh"
alias ls='lsd -1'
alias l='ls -l'
alias la='ls -a'
alias lla='ls -la'
alias lt='ls --tree'
alias sonar-scanner="source /etc/profile.d/sonar-scanner.sh && sonar-scanner"
alias gpg-fix="export GPG_TTY=$(tty)"
