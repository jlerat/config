# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions

module load miniconda3

module load openmpi

# Show folder structure
alias tree2="tree -dC -L 2"
alias tree3="tree -dC -L 3"

# Disable automatic removal of files
alias mv="mv -i"
alias cp="cp -i"
alias rm="rm -i"
alias ls="ls -a --color"

# Update nriv packages
alias pupdate="/datasets/work/lw-resilient-nr/work/0_Common_Data/5_Software/1_Python/conda/update_packages.sh env_nriv_v3"

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

# work spaces
export NAWRA_WORK=/datasets/work/lw-rowra/work/2_Hydrology/201_SG/0_Working/2_Julien/
export SCR=/scratch2/ler015

export NRIV=/datasets/work/lw-resilient-nr/work
export NWORK=/datasets/work/lw-resilient-nr/work/2_Hydrology/0_Working/1_Julien
export NCONDA=/datasets/work/lw-resilient-nr/work/0_Common_Data/5_Software/1_Python/conda
export NDPROC=/datasets/work/lw-resilient-nr/work/0_Common_Data/8_DataProcessingScripts/nrivdatascripts
export NRPROC=/datasets/work/lw-resilient-nr/work/6_Reporting/1_ReportProcessingScripts/nrivreportingscripts
export NHYDRO=/datasets/work/lw-resilient-nr/work/2_Hydrology
export NFFREQ=/datasets/work/lw-resilient-nr/work/2_Hydrology/2_FloodFrequencyAnalysis/0_DataProcessingScripts/nrivfloodfreqscripts
export NFVOL=/datasets/work/lw-resilient-nr/work/2_Hydrology/3_FloodVolumeEstimate/0_DataProcessingScripts/nrivfloodvolscripts
export NFCVP=/datasets/work/lw-resilient-nr/work/2_Hydrology/2_FloodFrequencyAnalysis/6_covariate_paper/covariate_paper

# Telemac-mascaret folders
export HOMETEL=$NCONDA/src/telemac-mascaret
export SYSTELCFG=$HOMETEL/configs/systel.cfg
export USETELCFG=gfortranHPC
export SOURCEFILE=$HOMETEL/configs/pysource.gfortranHPC.sh
#export METISHOME=~/opt/metis-5.1.0

showfolders ()
{
    echo ""
    echo " NAWRA_WORK: " $NAWRA_WORK
    echo " SCR       : " $SCR
    echo " "
    echo "-- Northern rivers --"
    echo " NRIV      : " $NRIV
    echo " NCONDA    : " $NCONDA
    echo " NDPROC    : " $NDPROC
    echo " NRPROC    : " $NRPROC
    echo " NHYDRO    : " $NHYDRO
    echo " NFFREQ    : " $NFFREQ
    echo " NFVOL     : " $NFVOL
    echo " NFCVP     : " $NFCVP 
    echo " NWORK     : " $NWORK
    echo " HOMETEL   : " $HOMETEL
    echo ""
}

jobres ()
{
    sacct --format=JobID,elapsed%10,ncpus%5,ExitCode%8,Start%20,End%20,state -j $1
}

# Git fetch and merge forward
gfetch ()
{
    git fetch $1 --prune
    git merge --ff-only $1/$2 || git rebase --preserve-merges $1/$2
}

glog()
{
    printf "\n-------- Last $1 logs --------\n\n"
    git log -$1 --pretty="%h %s (%ad)" | xargs -I message printf message"\n\n"
}

gpam ()
{
    printf "\n-------- Pull from git azure master -----\n\n"
    git pull azure master
    glog 3
}

# Analyse log files
logcheck()
{
    printf "\n-------- Jobs found in $1 --------\n"
    jobs=$(python ~/findjobs.py $1)
    jobsa=($jobs)
    echo $jobs


    for job in "${jobsa[@]}"
    do
        printf "\n-------- Analyse error files for JOB $job --------\n"
        echo "Nb jobs started           : " $(ls $1/*JOB$job.err | wc -l) || true
        echo "Nb jobs with errors       : " $(grep 'error' $1/*JOB$job.err | wc -l) || true
    done

 
    printf "\n-------- Analyse log files in $1 --------\n"
    echo "Nb processes started      : " $(grep 'Process started' $1/*.log | wc -l) || true
    echo "Nb processes completed    : " $(grep 'Process completed' $1/*.log | wc -l) || true
    echo "Nb processes with warnings: " $(grep 'WARNING' $1/*.log | wc -l) || true
    echo "Nb processes with errors  : " $(grep 'Err' $1/*.log | wc -l) || true

    
    printf "\n-------- Missing log files from task numbers in $1 --------\n"
    echo $(python ~/findtasks.py $1)
    printf "\n"
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

