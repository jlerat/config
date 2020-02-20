
# Display the machine os
cat /etc/os-release

# Refresh
sudo yum update

# Dev tools
sudo yum group install "Development tools"

# Git
sudo yum install git -y

# Python
sudo yum install python3 python3-devel -y
python3 -m pip install --user numpy pandas matplotlib scipy cython nose

# Clone repos
mkdir Code
cd Code
git clone https://bitbucket.org/jlerat/hydrodiy.git

