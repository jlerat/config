# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions

# Disable automatic removal of files
alias mv="mv -i"
alias cp="cp -i"
alias rm="rm -i"
alias ls="ls -a --color"

# Function to find text
wherein ()
{
    for i in $(find "$1" -type f 2> /dev/null); 
    do
        if grep -n --color=auto -i "$2" "$i" 2> /dev/null; then
            echo -e "\033[0;32mFound in: $i \033[0m\n";
        fi
    done
}

# Git commit
gcommit ()
{
    # Get date
    export GIT_COMMITTER_DATE=$(python -c "import newdate; print(newdate.latedate())" 2>&1) 
    echo "Commit date set to    :" $GIT_COMMITTER_DATE
    echo "Commit message set to :" $1
    # Run commit command
    git commit -m "$1" --date="$GIT_COMMITTER_DATE"
}

# added by Anaconda3 installer
export PATH="/home/julien/anaconda3/bin:$PATH"

# Git fetch and merge forward
gfetch ()
{
    git fetch $1 --prune
    git merge --ff-only $1/$2 || git rebase --preserve-merges $1/$2
}
