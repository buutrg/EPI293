######################## Lab 3 ########################

################## Install environment (if not already installed) ##################
# Download Miniconda
mkdir -p ~/miniconda3
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda3/miniconda.sh
bash ~/miniconda3/miniconda.sh -b -u -p ~/miniconda3
rm ~/miniconda3/miniconda.sh

# Install environment
conda env create -f epi293_environment.yml

######################################################################################

mkdir ~/lab3
cd ~/lab3

wget https://csg.sph.umich.edu/abecasis/metal/download/Linux-metal.tar.gz
tar -xzf Linux-metal.tar.gz

export PATH=$PATH:~/lab3/metal # Add metal to PATH

# Activate environment
conda activate epi293

# Computationally requirements: 4GB RAM, 1 core
# conda activate /n/holystore01/LABS/price_lab/Lab/btruong/conda_env/epi293

MY_WORKING_DIR=/n/netscratch/liang_lab/Lab/btruong/EPI293_GeneticData/
cd ${MY_WORKING_DIR}

GENETIC_DIR=/n/netscratch/liang_lab/Lab/btruong/EPI293_GeneticData

bed=${GENETIC_DIR}/genotype_bed/genotyped_affy_hpfs
pheno=${GENETIC_DIR}/hpfs_data.txt
covar=${GENETIC_DIR}/hpfs_data.txt

phenoCol=bmi

mkdir -p ${GENETIC_DIR}/step1

step1_prefix=${GENETIC_DIR}/step1/hpfs_bmi_step1

regenie \
    --step 1 \
    --bed ${bed} \
    --phenoFile ${pheno} \
    --covarFile ${covar} \
    --phenoCol ${phenoCol} \
    --apply-rint \
    --covarCol ageyr,PC1,PC2,PC3,PC4,PC5,PC6,PC7,PC8,PC9,PC10 \
    --pThresh 0.01 \
    --bsize 1000 --force-step1 --lowmem \
    --out ${step1_prefix}

# For binary traits replace `--apply-rint` with `--bt --firth --approx`


#################### RUN REGENIE STEP 2 #################### 
# ${MY_WORKING_DIR}/regenie_step2.sh


#!/bin/bash
#SBATCH -c 1 # Number of cores requested
#SBATCH -t 00-00:10 # Runtime in minutes
#SBATCH -p hsph # Partition to submit to
#SBATCH -o %x.%A_%a.out # Standard out goes to this file
#SBATCH -e %x.%A_%a.err # Standard err goes to this filehostname

source ~/.bashrc

conda activate /n/holystore01/LABS/price_lab/Lab/btruong/conda_env/epi293

chr=$SLURM_ARRAY_TASK_ID

cd ${MY_WORKING_DIR}

# Replace this with your genetic data directory
GENETIC_DIR=/n/netscratch/liang_lab/Lab/btruong/EPI293_GeneticData

bed=${GENETIC_DIR}/bed/chr${chr}
pheno=${GENETIC_DIR}/hpfs_data.txt
covar=${GENETIC_DIR}/hpfs_data.txt

phenoCol=bmi

mkdir -p ${GENETIC_DIR}/step2

step1_prefix=${GENETIC_DIR}/step1/hpfs_${phenoCol}_step1
step2_prefix=${GENETIC_DIR}/step2/hpfs_${phenoCol}_step2

regenie \
    --step 2 \
    --bed ${bed} \
    --phenoFile ${pheno} \
    --covarFile ${covar} \
    --phenoCol ${phenoCol} \
    --apply-rint \
    --covarCol ageyr,PC1,PC2,PC3,PC4,PC5,PC6,PC7,PC8,PC9,PC10 \
    --pThresh 0.01 \
    --bsize 1000 \
    --pred ${step1_prefix}_pred.list \
    --bsize 1000 \
    --out ${step2_prefix}_chr${chr}

# For binary traits replace `--apply-rint` with `--bt --firth --approx`

########################

MY_WORKING_DIR=/n/netscratch/liang_lab/Lab/btruong/EPI293_GeneticData/
mkdir -p ${MY_WORKING_DIR}/log_files

sbatch \
    -J regenie_step2 \
    --chdir ${MY_WORKING_DIR}/log_files \
    --mem=8G \
    --array=1-6 \
    -t 00-1:30 \
    --export=ALL,MY_WORKING_DIR=${MY_WORKING_DIR} \
    ${MY_WORKING_DIR}/regenie_step2.sh

############################
