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
if [ -z "$1" ]
then
    echo "ERROR - Expected an envname argument"
    exit 1
fi

# Select path to conda data
FCONDAS=(
    /datasets/ev-richmondflood/work/8_Software/conda
    /datasets/work/ev-richmondflood/work/8_Software/conda
)
MACHINES=(vm pet)
for ((i=0; i<${#FCONDAS[@]}; i++)); do
    FPATH="${FCONDAS[$i]}"
    if [ -e "$FPATH" ]; then
        FCONDA=$FPATH
        MACHINE="${MACHINES[$i]}"
        break
    fi    
done

FILENAME=$(basename "$0")
FLOG=$FCONDA/${FILENAME%.*}.log
echo ------------------------------------------------- > $FLOG
echo Start time : $(date) >> $FLOG
echo Target folder : $FCONDA >> $FLOG
echo Creating or updating environment $ENVNAME >> $FLOG
echo Working in machine $MACHINE >> $FLOG
echo ------------------------------------------------- >> $FLOG
echo >> $FLOG

#module load miniconda3

# Set directories
export CONDA_PKGS_DIRS=$FCONDA/pkgs
export CONDA_ENVS_DIRS=$FCONDA/envs
export CONDA_ENVS_FILES_DIRS=$FCONDA/envs_yml_files
export CONDA_PKGS_SRC=$FCONDA/src

TEST_DIRS=(
    $FCONDA
    $CONDA_PKGS_DIRS
    $CONDA_ENVS_DIRS
    $CONDA_ENVS_FILES_DIRS
    $CONDA_PKGS_SRC
)
for test_dir in "${TEST_DIRS[@]}"; do
    if [ ! -d "$test_dir" ]; then
        echo "ERROR - directory does not exist ($test_dir)."
        exit 1
    fi
done    
echo "Directories existence checked." >> $FLOG

echo >> $FLOG
echo CONDA info >> $FLOG
conda info >> $FLOG

echo >> $FLOG
echo +++ Creating CONDA env +++ >> $FLOG
echo >> $FLOG

# Create Yaml file
YAMLFILE_SRC=$CONDA_ENVS_FILES_DIRS/$ENVNAME.yml
if [ ! -f "$YAMLFILE_SRC" ]; then
    echo "ERROR - Yaml file does not exist ($YAMLFILE_SRC)."
    exit 1
fi
echo "Yaml file existence checked." >> $FLOG
echo >> $FLOG

ENVNAME_MACHINE=$ENVNAME\_$MACHINE
YAMLFILE=$CONDA_ENVS_FILES_DIRS/$ENVNAME_MACHINE.yml

sed "s/$ENVNAME/$ENVNAME_MACHINE/g" $YAMLFILE_SRC > $YAMLFILE
echo "Yaml file processed." >> $FLOG
echo >> $FLOG

# Create env
FENV=$CONDA_ENVS_DIRS/$ENVNAME_MACHINE
if [ ! -d "$FENV" ]; then
    echo Environment $ENVNAME_MACHINE does not exist. Create
    echo ".. Creating conda env"
    conda env create --file=$YAMLFILE --prefix $CONDA_ENVS_DIRS/$ENVNAME_MACHINE >> $FLOG
fi

# -------------------------------------------------------------------------
echo >> $FLOG
echo ----------------------------------- >> $FLOG
echo Activate CONDA env >> $FLOG
conda activate $ENVNAME_MACHINE

# Set tmp dir in case there is not enough space in the original tmp 
TMPDIR=$FCONDA/tmp
mkdir -p $TMPDIR

# -------------------------------------------------------------------------
for PACKAGE in "hydrodiy" "pygme" "floodstan" \
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
