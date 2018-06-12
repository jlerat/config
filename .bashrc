# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# Disable automatic removal of files
alias mv="mv -i"
alias cp="cp -i"
alias rm="rm -i"
alias ls="ls -a --color"

# Function to find text
# usage: wherein /path pattern
# 
wherein ()
{
    for i in $(find "$1" -type f 2> /dev/null); 
    do
        if grep -n --color=auto -i "$2" "$i" 2> /dev/null; then
            echo -e "\033[0;32mFound in: $i \033[0m\n";
        fi
    done
}
