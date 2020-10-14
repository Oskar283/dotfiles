alias ll="ls -la"

alias ..='cd ..'
alias ...='cd ../../'
alias ....='cd ../../../'
alias .....='cd ../../../../'

# Deletes all git branches except master
alias delete_git_branches="git for-each-ref --format '%(refname:short)' refs/heads | grep -v master | xargs git branch -D"

alias p3="python3"

alias gen_ctags='~/.vim/configs/universal-ctags/ctags -R -f"tags" --languages=-javascript,sql,css --map-TTCN=+.ttcnpp'

alias ved="git ls-files --full-name | dmenu -i -l 20 | xargs /bin/bash -c 'vim \"\$1\" < /dev/tty' vim"
alias vi="vi -u NONE"
