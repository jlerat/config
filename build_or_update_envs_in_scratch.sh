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

MACHINE=$2
if [ -z "$2" ]
then
    echo "ERROR - Expected a machine argument"
    exit 1
fi


# Select path to conda data
declare -A FCONDAS
FCONDAS["vm"]="/datasets/ev-richmondflood/work/8_Software/conda"
FCONDAS["pet"]="/datasets/work/ev-richmondflood/work/8_Software/conda"
FCONDAS["sc"]="/scratch3/ler015/conda"
if [[ -v FCONDAS["$MACHINE"] ]]; then
    FCONDA="${FCONDAS[$MACHINE]}"
else    
    echo "ERROR - Cannot find conda path for machine $MACHINE"
    exit 1
fi

FILENAME=$(basename "$0")
FLOG=$FCONDA/${FILENAME%.*}.log
echo ------------------------------------------------- > $FLOG
echo Start time : $(date) >> $FLOG
echo Target folder : $FCONDA >> $FLOG
echo Creating or updating environment $ENVNAME >> $FLOG
echo Working in machine $MACHINE >> $FLOG
echo ------------------------------------------------- >> $FLOG
echo >> $FLOG

# Set directories
export CONDA_PKGS_DIRS=$FCONDA/pkgs
export CONDA_ENVS_DIRS=$FCONDA/envs
export CONDA_ENVS_FILES_DIRS=~/conda/envs_yml_files
export CONDA_PKGS_SRC=$FCONDA/src

TEST_DIRS=(
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
export CONDA_VERBOSITY=2
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
YAMLFILE=$CONDA_ENVS_DIRS/$ENVNAME_MACHINE.yml

sed "s/$ENVNAME/$ENVNAME_MACHINE/g" $YAMLFILE_SRC > $YAMLFILE
echo "Yaml file processed." >> $FLOG
echo >> $FLOG

# Create env
FENV=$CONDA_ENVS_DIRS/$ENVNAME_MACHINE
if [ ! -d "$FENV" ]; then
    echo Environment $ENVNAME_MACHINE does not exist. Create >> $FLOG
    conda clean --all
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
declare -A GIT_REPO_URLS

GIT_REPO_URLS[hydrodiy]=git@github.com:csiro-hydroinformatics/hydrodiy.git
GIT_REPO_URLS[pygme]=git@github.com:csiro-hydroinformatics/pygme.git
GIT_REPO_URLS[pyquasoare]=git@github.com:csiro-hydroinformatics/pyquasoare.git
GIT_REPO_URLS[floodstan]=git@github.com:jlerat/floodstan.git
GIT_REPO_URLS[hyncu]=git@github.com:jlerat/hyncu.git
GIT_REPO_URLS[termplot]=git@github.com:jlerat/termplot.git
GIT_REPO_URLS[pyflood2022]=git@github.com:jlerat/pyflood2022.git
GIT_REPO_URLS[hyzarr]=git@ssh.dev.azure.com:v3/ler015/hyzarr/hyzarr
GIT_REPO_URLS[nrivdata]=git@ssh.dev.azure.com:v3/ler015/northern_rivers/nrivdata

PACKAGES_TO_INSTALL=(hydrodiy pygme floodstan hyncu termplot \
                     pyquasoare pyflood2022)
for PACKAGE in "${PACKAGES_TO_INSTALL[@]}"; do
    echo >> $FLOG
    echo ----------------------------------- >> $FLOG
    echo Installing $PACKAGE >> $FLOG
    echo  >> $FLOG
    FPACK=$CONDA_PKGS_SRC/$PACKAGE

    # Get repo url and remote name
    GIT_REPO_URL="${GIT_REPO_URLS[$PACKAGE]}"
    if echo $GIT_REPO_URL | grep -q "github"; then
        GIT_REMOTE_NAME=github
    else
        GIT_REMOTE_NAME=azure
    fi    
    echo    Git repos [$PACKAGE]: \($GIT_REMOTE_NAME\) $GIT_REPO_URL >> $FLOG

    if [ -d "$FPACK" ]; then
        echo    "$PACKAGE folder exists. Git pull from $GIT_REMOTE_NAME" >> $FLOG
        cd $FPACK
        git remote rename origin $GIT_REMOTE_NAME
        git checkout -b master
        git pull $GIT_REMOTE_NAME master
        git reset --hard HEAD
    else
        echo    "$PACKAGE folder does not exist. Git clone from $GIT_REMOTE_NAME" >> $FLOG
        cd $CONDA_PKGS_SRC
        git clone $GIT_REPO_URL

        # Set name of git server 
        cd $FPACK
        git remote rename origin $GIT_REMOTE_NAME
    fi

    # Install package in environment
    export TMPDIR=$TMPDIR; pip install -e .

done
