#!/bin/bash -l

# ----------------------------------
# Script to create conda environment in 
# the scratch2 folder.
# The script:
#   1. Create folders /scracth2/ler015/conda, 
#      /scratch2/ler015/conda/envs and 
#      /scratch2/ler015/conda/pkg
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

FILENAME=$(basename $0)
FLOG=~/conda/${FILENAME%.*}.log
echo ------------------------------------------------- > $FLOG
echo Creating or updating environment $ENVNAME >> $FLOG
echo ------------------------------------------------- >> $FLOG
echo >> $FLOG

module load miniconda3

# conda dir on scratch
FCONDA=/scratch2/ler015/conda
mkdir -p $FCONDA

# Set directories
export CONDA_PKGS_DIRS=$FCONDA/pkg
mkdir -p $CONDA_PKGS_DIRS

export CONDA_ENVS_DIRS=$FCONDA/envs
mkdir -p $CONDA_ENVS_DIRS

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

YAMLFILE=$CONDA_ENVS_DIRS/$ENVNAME.yml
echo "YAML file : $YAMLFILE" >> $FLOG

# Yaml file
# CAUTION! We assume that the environment name given 
# within the YAML file is the same than the file name.
if [ ! -f "$YAMLFILE" ]; then
    echo YAML file $YAMLFILE does not exist. Copy from home
    cp ~/conda/envs/$ENVNAME.yml $YAMLFILE
fi

FENV=$CONDA_ENVS_DIRS/$ENVNAME
if [ ! -d "$FENV" ]; then
    echo Environment $ENVNAME does not exist. Create
    conda env create --file=$YAMLFILE --prefix $FCONDA/envs/$ENVNAME 
fi

# -------------------------------------------------------------------------
echo >> $FLOG
echo ----------------------------------- >> $FLOG
echo Activate CONDA env >> $FLOG
conda activate $ENVNAME

# -------------------------------------------------------------------------
for PACKAGE in "hydrodiy" "hyzarr" "nrivplot" "nrivdata" \
                        "nrivfloodfreq" "pygme"
do
    echo >> $FLOG
    echo ----------------------------------- >> $FLOG
    echo Installing $PACKAGE >> $FLOG
    echo  >> $FLOG
    FPACK=$CONDA_PKGS_SRC/$PACKAGE
   
    # Name of git repos on azure depending if the
    # package name starts with nriv
    if [[ $PACKAGE == nriv* ]]; then
        REPOS=git@ssh.dev.azure.com:v3/ler015/northern_rivers/$PACKAGE
    else
        REPOS=git@ssh.dev.azure.com:v3/ler015/$PACKAGE/$PACKAGE
    fi
    echo   Git repos: $REPOS >> $FLOG

    if [ -d "$FPACK" ]; then
        echo   "$PACKAGE folder exists. Git pull from azure" >> $FLOG
        cd $FPACK
        git pull azure master
    else
        echo   "$PACKAGE folder does not exist. Git clone from azure" >> $FLOG
        cd $CONDA_PKGS_SRC
        git clone $REPOS

        # Set name of git server as "azure"
        cd $FPACK
        git remote rename origin azure
    fi

    # Install package in environment
    pip install -e .


done
