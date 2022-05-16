# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions

# Show folder structure
alias tree2="tree -dC -L 2"
alias tree3="tree -dC -L 3"

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

glog()
{
    printf "\n-------- Last $1 logs --------\n\n"
    git log -$1 --pretty="%h %s" | xargs -I message printf message"\n\n"
}

# Analyse log files
logcheck()
{
    printf "\n-------- Analyse log files in $1 --------\n"
    echo "Nb proc started     : " $(grep 'Process started' $1/*.log | wc -l)
    echo "Nb proc completed   : " $(grep 'Process completed' $1/*.log | wc -l)
    echo "Nb proc with errrors: " $(grep 'Err' $1/*.log | wc -l)
    printf "\n"
}

# Parallel run of python scripts
pararun()
{
    # Parse arguments
    SCRIPT_FILE=$(python -c "import sys; print(sys.argv[1])" $@ 2>&1) 
    NBATCH=$(python -c "import sys; print(int(sys.argv[2]))" $@ 2>&1) 
    
    echo "script = "$SCRIPT_FILE
    echo "nbatch = "$NBATCH
    echo "script arguments = " ${@:3}
    
    let NMAX=NBATCH-1
    for IBATCH in `seq 0 $NMAX`;
    do
        echo "Started script "$SCRIPT_FILE" - ibatch = " $IBATCH
        nohup python $SCRIPT_FILE -i $IBATCH -n $NBATCH ${@:3} &
        echo "Completed script "$SCRIPT_FILE" - ibatch = " $IBATCH
    done
}

# Update all git repos
fetchall()
{
    CPATH=$HOME/Code
    declare -a ALLREPOS=(\
        "hydrodiy" \
        "hync" \
    )

    for repos in "${ALLREPOS[@]}"
    do
        echo "----- Fetching repos $repos -----"
        cd $CPATH/$repos
        gfetch origin master
    done
}




