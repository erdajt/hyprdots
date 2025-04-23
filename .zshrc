export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

plugins=(git zsh-vi-mode)

source $ZSH/oh-my-zsh.sh

ZVM_INSERT_MODE_CURSOR=$ZVM_CURSOR_STEADY_BLOCK
ZVM_NORMAL_MODE_CURSOR=$ZVM_CURSOR_STEADY_BLOCK


# SETTINGS
HIST_STAMPS="dd.mm.yyyy"
DISABLE_AUTO_TITLE="true"
export LANG=en_US.UTF-8

# editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='mvim'
fi

# ALIASES
alias zshconfig="nvim ~/.zshrc"
alias ohmyzsh="nvim ~/.oh-my-zsh"
remindme() {
  notify-send "$@" -h int:transient:1 -t 0
}

# go
export PATH="$HOME/.goenv/bin:$PATH"
eval "$(goenv init -)"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# java & android
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk/
export PATH=$JAVA_HOME/bin:$PATH

export ANDROID_HOME=$HOME/Android/Sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/platform-tools
export PATH=$PATH:$ANDROID_HOME/tools
