#!/bin/bash -l

# ----------------------------------
# Script to create conda environment in 
# the scratch2 folder.
# The script:
#   1. Create folders $FCONDA/conda, 
#                     $FCONDA/conda/envs
#                     $FCONDA/conda/pkgs
#
#   2. Copies the env.yml file from ~/conda/envs
#
#   3. Create the env if it does not exists and 
#      load its.
#
#   4. Clone or update all packages listed below
#
#   5. Install the package using setup.py
#
# author: Julien Lerat, CSIRO Env
# date : 2023-05-23 Tue 11:00 AM
# ----------------------------------

# Get environment name
ENVNAME=$1

# Get target folder
FCONDA=/datasets/work/ev-richmondflood/work/8_Software/conda

FILENAME=$(basename $0)
FLOG=~/conda/${FILENAME%.*}.log
echo ------------------------------------------------- > $FLOG
echo Target folder : $FCONDA >> $FLOG
echo Creating or updating environment $ENVNAME >> $FLOG
echo ------------------------------------------------- >> $FLOG
echo >> $FLOG

module load miniconda3

# conda dir on scratch
mkdir -p $FCONDA

# Set directories
export CONDA_PKGS_DIRS=$FCONDA/pkgs
mkdir -p $CONDA_PKGS_DIRS

export CONDA_ENVS_DIRS=$FCONDA/envs
mkdir -p $CONDA_ENVS_DIRS

export CONDA_ENVS_FILES_DIRS=$FCONDA/envs_yml_files

export CONDA_PKGS_SRC=$FCONDA/src
mkdir -p $CONDA_PKGS_SRC

# -------------------------------------------------------------------------
echo >> $FLOG
echo ----------------------------------- >> $FLOG
echo CONDA info >> $FLOG
conda info >> $FLOG

# -------------------------------------------------------------------------
echo >> $FLOG
echo ----------------------------------- >> $FLOG
echo Creating CONDA env >> $FLOG
echo >> $FLOG

YAMLFILE=$CONDA_ENVS_FILES_DIRS/$ENVNAME.yml

# Yaml file
# CAUTION! We assume that the environment name given 
# within the YAML file is the same than the file name.

FENV=$CONDA_ENVS_DIRS/$ENVNAME
if [ ! -d "$FENV" ]; then
    echo Environment $ENVNAME does not exist. Create
    echo ".. Creating conda env"
    conda env create --file=$YAMLFILE --prefix $CONDA_ENVS_DIRS/$ENVNAME >> $FLOG
fi

# -------------------------------------------------------------------------
echo >> $FLOG
echo ----------------------------------- >> $FLOG
echo Activate CONDA env >> $FLOG
conda activate $ENVNAME

# -------------------------------------------------------------------------
for PACKAGE in "hydrodiy" "hyzarr" "nrivplot" "nrivdata" \
                        "nrivfloodfreq" "pygme" "floodstan" \
                        "termplot" "pyquasoare" "pyflood2022"
do
    echo >> $FLOG
    echo ----------------------------------- >> $FLOG
    echo Installing $PACKAGE >> $FLOG
    echo  >> $FLOG
    FPACK=$CONDA_PKGS_SRC/$PACKAGE
   
    # Name of git repos on azure depending if the
    # package name starts with nriv
    if [[ $PACKAGE == nriv* ]]; then
        GIT_REMOTE_NAME=azure
        GIT_REMOTE_URL=git@ssh.dev.azure.com:v3/ler015/northern_rivers/$PACKAGE
    elif [[ $PACKAGE == hyzarr ]]; then
        GIT_REMOTE_NAME=azure
        GIT_REMOTE_URL=git@ssh.dev.azure.com:v3/ler015/hyzarr/hyzarr
    elif [[ $PACKAGE == hydrodiy ]]; then
        GIT_REMOTE_NAME=github
        GIT_REMOTE_URL=git@github.com:csiro-hydroinformatics/hydrodiy.git
    elif [[ $PACKAGE == pygme ]]; then
        GIT_REMOTE_NAME=github
        GIT_REMOTE_URL=git@github.com:csiro-hydroinformatics/pygme.git
    elif [[ $PACKAGE == pyquasoare ]]; then
        GIT_REMOTE_NAME=github
        GIT_REMOTE_URL=git@github.com:csiro-hydroinformatics/pyquasoare.git
    else
        GIT_REMOTE_NAME=github
        GIT_REMOTE_URL=git@github.com:jlerat/$PACKAGE.git
    fi
    echo   Git repos: $GIT_REMOTE_URL >> $FLOG

    if [ -d "$FPACK" ]; then
        echo   "$PACKAGE folder exists. Git pull from $GIT_REMOTE_NAME" >> $FLOG
        cd $FPACK
        git remote rename origin $GIT_REMOTE_NAME
        git pull $GIT_REMOTE_NAME master
        git reset --hard HEAD
    else
        echo   "$PACKAGE folder does not exist. Git clone from $GIT_REMOTE_NAME" >> $FLOG
        cd $CONDA_PKGS_SRC
        git clone $GIT_REMOTE_URL

        # Set name of git server 
        cd $FPACK
        git remote rename origin $GIT_REMOTE_NAME
    fi

    # Install package in environment
    pip install -e .


done
