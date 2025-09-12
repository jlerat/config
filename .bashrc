# .bashrc
# t

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions

module load miniconda3
module load valgrind
module load openmpi

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

gpam ()
{
    printf "\n-------- Pull from git azure master -----\n\n"
    git pull azure master
    glog 3
}

gppam ()
{
    printf "\n-------- Push to git azure master -----\n\n"
    read -p "Are you sure? " -n 1 -r
    echo    # (optional) move to a new line
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        git push azure master
    fi
    glog 3
}

gpgm ()
{
    printf "\n-------- Pull from git github master -----\n\n"
    git pull github master
    glog 3
}

gppgm ()
{
    printf "\n-------- Push to git github master -----\n\n"
    read -p "Are you sure? " -n 1 -r
    echo    # (optional) move to a new line
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        git push github master
    fi
    glog 3
}

# Analyse log files
logcheck()
{
    python ~/logcheck.py $1
}


# View csv file
viewcsv()
{
    column -s, -t < $1 | less -#2 -N -S
}

# Update all repos
update_repos()
{
    for f in *; do echo "Updating $f .."; cd $f; git pull github master | true; cd ..; done
} 

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/apps/miniconda3/4.9.2/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/apps/miniconda3/4.9.2/etc/profile.d/conda.sh" ]; then
        . "/apps/miniconda3/4.9.2/etc/profile.d/conda.sh"
    else
        export PATH="/apps/miniconda3/4.9.2/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

