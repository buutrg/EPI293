
# Download Miniconda
mkdir -p ~/miniconda3
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda3/miniconda.sh
bash ~/miniconda3/miniconda.sh -b -u -p ~/miniconda3
rm ~/miniconda3/miniconda.sh

# Request a small node to install the environment
srun --pty -p general -t 0-6:00 --mem 8G /bin/bash

# Activate the environment
source ~/miniconda3/bin/activate

# Initialize the environment
conda init --all

# Install the environments
conda env create -f ~/165993/epi293/Data/epi293_environment.yml
conda env create -f ~/165993/epi293/Data/genomicsem.env.yml

# Activate environment
conda activate epi293

# Provide the output of the following commands in the google form:
which regenie
which plink2
which plink
which R


