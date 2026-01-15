######################## Lab 3 ########################
# Run Regenie step 1 for each platform
# ~/165993/epi293/Lab3/scripts/regenie_step1.sh


# Computationally requirements: 8GB RAM, 1 core
# Request a small node to run the script
srun --pty -p general -t 0-6:00 --mem 8G -c 4 /bin/bash

# Activate environment
conda activate epi293

EPI293_GENETIC_DIR=~/165993/epi293/EPI293_GeneticData/
EPI293_TRAIT_DIR=~/165993/epi293/EPI293_TraitData/
MY_HOME=~

cd ${MY_HOME}

MY_WORKING_DIR=${MY_HOME}/lab3
mkdir -p ${MY_WORKING_DIR}
cd ${MY_WORKING_DIR}

# Download and extract METAL for Meta-analysis
wget https://csg.sph.umich.edu/abecasis/metal/download/Linux-metal.tar.gz -O ${MY_WORKING_DIR}/Linux-metal.tar.gz
tar -xzf ${MY_WORKING_DIR}/Linux-metal.tar.gz
export PATH=${MY_WORKING_DIR}/generic-metal/:$PATH # Add metal to PATH



#################### RUN REGENIE STEP 1 #################### 
# ~/165993/epi293/Lab3/scripts/regenie_step1.sh


#!/bin/bash
#SBATCH -c 4 # Number of cores requested
#SBATCH -t 00-2:00 # Runtime in minutes
#SBATCH -p general # Partition to submit to
#SBATCH -o %x.%A_%a.out # Standard out goes to this file
#SBATCH -e %x.%A_%a.err # Standard err goes to this filehostname

source ~/.bashrc

conda activate epi293

# platform=AffymetrixData
# platform_short=Affy

GENETIC_PLATFORM_DIR=${EPI293_GENETIC_DIR}/platform_${platform}

bed=${GENETIC_PLATFORM_DIR}/genotype_${platform_short} # bed file goes with platform_short name
pheno=${EPI293_TRAIT_DIR}/hpfs_pheno_covar.txt # phenotype file
covar=${EPI293_TRAIT_DIR}/hpfs_pheno_covar.txt # covariate file (here example is the same as phenotype file)

ls ${bed}*
head ${pheno}

phenoCol=bmi

mkdir -p ${MY_WORKING_DIR}/platform_${platform}/regenie/step1

step1_prefix=${MY_WORKING_DIR}/platform_${platform}/regenie/step1/hpfs_bmi_step1

regenie \
    --step 1 \
    --bed ${bed} \
    --threads 4 \
    --phenoFile ${pheno} \
    --covarFile ${covar} \
    --phenoCol ${phenoCol} \
    --apply-rint \
    --covarCol ageyr,PC1,PC2,PC3,PC4,PC5,PC6,PC7,PC8,PC9,PC10 \
    --pThresh 0.01 \
    --bsize 1000 --force-step1 --lowmem \
    --out ${step1_prefix}

# For binary traits replace `--apply-rint` with `--bt --firth --approx`


##########################

EPI293_GENETIC_DIR=~/165993/epi293/EPI293_GeneticData/
EPI293_TRAIT_DIR=~/165993/epi293/EPI293_TraitData/
MY_HOME=~

cd ${MY_HOME}


MY_WORKING_DIR=${MY_HOME}/lab3
mkdir -p ${MY_WORKING_DIR}/log_files

# Define platform, replace with the platform you want to analyze
platform_list=("AffymetrixData" "GlobalScreeningArrayData" "HumanCoreExData2" "IlluminaHumanHapData" "OmniExpressData" "OncoArrayData")
platform_short_list=("Affy" "GSAD" "Core" "Illu" "Omni" "Onco")

for ((i=0; i<${#platform_list[@]}; i++)); do

    platform=${platform_list[$i]}
    platform_short=${platform_short_list[$i]}
    echo $platform $platform_short
    
    sbatch \
        -J regenie_step1_${platform} \
        --chdir ${MY_WORKING_DIR}/log_files \
        --mem=8G \
        -c 4 \
        -t 00-1:30 \
        --export=ALL,MY_WORKING_DIR=${MY_WORKING_DIR},GENETIC_PLATFORM_DIR=${GENETIC_PLATFORM_DIR},EPI293_TRAIT_DIR=${EPI293_TRAIT_DIR},platform=${platform},platform_short=${platform_short} \
        ~/165993/epi293/Lab3/scripts/regenie_step1.sh

done

#################### RUN REGENIE STEP 2 #################### 
# ~/165993/epi293/Lab3/scripts/regenie_step2.sh


#!/bin/bash
#SBATCH -c 4 # Number of cores requested
#SBATCH -t 00-2:00 # Runtime in minutes
#SBATCH -p general # Partition to submit to
#SBATCH -o %x.%A_%a.out # Standard out goes to this file
#SBATCH -e %x.%A_%a.err # Standard err goes to this filehostname

source ~/.bashrc

conda activate epi293
# conda activate /n/holystore01/LABS/price_lab/Lab/btruong/conda_env/epi293

# chr=16
chr=$SLURM_ARRAY_TASK_ID

cd ${MY_WORKING_DIR}

pgen=${GENETIC_PLATFORM_DIR}/chr${chr}_${platform_short}
pheno=${EPI293_TRAIT_DIR}/hpfs_pheno_covar.txt
covar=${EPI293_TRAIT_DIR}/hpfs_pheno_covar.txt

ls ${pgen}*
head ${pheno}*

phenoCol=bmi

# Create step2 directory
mkdir -p ${MY_WORKING_DIR}/platform_${platform}/regenie/step2

step1_prefix=${MY_WORKING_DIR}/platform_${platform}/regenie/step1/hpfs_bmi_step1
step2_prefix=${MY_WORKING_DIR}/platform_${platform}/regenie/step2/hpfs_step2

regenie \
    --step 2 \
    --pgen ${pgen} \
    --phenoFile ${pheno} \
    --covarFile ${covar} \
    --phenoCol ${phenoCol} \
    --apply-rint \
    --threads 4 \
    --covarCol ageyr,PC1,PC2,PC3,PC4,PC5,PC6,PC7,PC8,PC9,PC10 \
    --pThresh 0.01 \
    --bsize 1000 \
    --pred ${step1_prefix}_pred.list \
    --bsize 1000 \
    --out ${step2_prefix}_chr${chr}

awk '{
    if (FNR==1) {print $0,"P"; next}
    P=10^(-$13+0)
    print $0,P
}' OFS=" " ${step2_prefix}_chr${chr}_bmi.regenie > ${step2_prefix}_chr${chr}_bmi_withP.regenie

rm ${step2_prefix}_chr${chr}_bmi.regenie

# For binary traits replace `--apply-rint` with `--bt --firth --approx`

########################


EPI293_GENETIC_DIR=~/165993/epi293/EPI293_GeneticData/
EPI293_TRAIT_DIR=~/165993/epi293/EPI293_TraitData/
MY_HOME=~


GENETIC_PLATFORM_DIR=${EPI293_GENETIC_DIR}/platform_${platform}/
MY_WORKING_DIR=${MY_HOME}/lab3/

echo $EPI293_GENETIC_DIR
echo $EPI293_TRAIT_DIR
echo $MY_WORKING_DIR

mkdir -p ${MY_WORKING_DIR}/log_files

platform_list=("AffymetrixData" "GlobalScreeningArrayData" "HumanCoreExData2" "IlluminaHumanHapData" "OmniExpressData" "OncoArrayData")
platform_short_list=("Affy" "GSAD" "Core" "Illu" "Omni" "Onco")

for ((i=0; i<${#platform_list[@]}; i++)); do

    platform=${platform_list[$i]}
    platform_short=${platform_short_list[$i]}
    echo $platform $platform_short

    sbatch \
        -J regenie_step2_${platform} \
        --chdir ${MY_WORKING_DIR}/log_files \
        --mem=8G \
        -c 4 \
        --array=16 \
        -t 00-1:30 \
        --export=ALL,MY_WORKING_DIR=${MY_WORKING_DIR},GENETIC_PLATFORM_DIR=${GENETIC_PLATFORM_DIR},EPI293_TRAIT_DIR=${EPI293_TRAIT_DIR},platform=${platform},platform_short=${platform_short} \
        ~/165993/epi293/Lab3/scripts/regenie_step2.sh

done

########################

# METAL script for meta-analysis

# Create meta-analysis directory
mkdir -p ${MY_WORKING_DIR}/meta_analysis
# Create METAL script
cat > ${MY_WORKING_DIR}/meta_analysis/metal_script.txt << EOF
# METAL script for GWAS meta-analysis

# Describe and process the input files
SCHEME STDERR

# Study 1
MARKER ID
ALLELE ALLELE0 ALLELE1
EFFECT BETA
STDERR SE
PVALUE P

PROCESS ${MY_WORKING_DIR}/platform_AffymetrixData/regenie/step2/hpfs_step2_chr16_bmi_withP.regenie

# Study 2
MARKER ID
ALLELE ALLELE0 ALLELE1
EFFECT BETA
STDERR SE
PVALUE P

PROCESS ${MY_WORKING_DIR}/platform_AffymetrixData/regenie/step2/hpfs_step2_chr16_bmi_withP.regenie

# Perform meta-analysis
OUTFILE meta_analysis_bmi_results .txt
ANALYZE HETEROGENEITY

QUIT
EOF

# Run METAL (uncomment when ready to execute)
metal ${MY_WORKING_DIR}/meta_analysis/metal_script.txt

########################



