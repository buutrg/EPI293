

conda install r-expm


######################## /n/holylfs05/LABS/liang_lab/Lab/btruong/Projects/EPI293/scripts/pgen_conversion.sh

#!/bin/bash
#SBATCH -c 1 # Number of cores requested
#SBATCH -t 00-00:10 # Runtime in minutes
#SBATCH -p hsph # Partition to submit to
#SBATCH --mem=16G # Memory per node in MB (see also --mem)
#SBATCH --chdir /n/holystore01/LABS/price_lab/Everyone/btruong/logs
#SBATCH -o %x.%A_%a.out # Standard out goes to this file
#SBATCH -e %x.%A_%a.err # Standard err goes to this filehostname

mkdir -p /n/netscratch/liang_lab/Lab/btruong/EPI293_GeneticData/platform_${array}
cd /n/netscratch/liang_lab/Lab/btruong/EPI293_GeneticData/platform_${array}

chr=$SLURM_ARRAY_TASK_ID

# chr=22

awk -v chr=${chr} '{
    split($0, a, ":");
    if (a[1]=="chr"chr && $7 > 0.8) {
        print $1
    }
}' ${DATA_DIR}/chr${chr}.info > chr${chr}_r2.0.8.info

plink2 \
    --vcf ${DATA_DIR}/chr${chr}.dose.vcf.gz dosage=DS \
    --extract chr${chr}_r2.0.8.info \
    --make-pgen \
    --out chr${chr}

plink2 \
    --pfile chr${chr} \
    --update-ids /n/netscratch/liang_lab/Lab/btruong/EPI293_GeneticData/hpfs_df_newID_${array_short}.txt \
    --keep /n/netscratch/liang_lab/Lab/btruong/EPI293_GeneticData/hpfs_df_newID_${array_short}_keep.txt \
    --make-pgen \
    --out chr${chr}_updatedIDS

mv chr${chr}_updatedIDS.pgen chr${chr}_${array_short}.pgen
mv chr${chr}_updatedIDS.pvar chr${chr}_${array_short}.pvar
mv chr${chr}_updatedIDS.psam chr${chr}_${array_short}.psam

rm -rf chr${chr}.pgen chr${chr}.pvar chr${chr}.psam

########################


cd /n/netscratch/liang_lab/Lab/btruong/EPI293_GeneticData

# rm -rf bed
# mkdir -p bed

array_topmed=("AffymetrixData" "GlobalScreeningArrayData" "HumanCoreExData2" "IlluminaHumanHapData" "OmniExpressData" "OncoArrayData")
array_short=("Affy" "GSAD" "Core" "Illu" "Omni" "Onco")

for ((i=0; i<${#array_topmed[@]}; i++)); do

    # i=1
    array=${array_topmed[$i]}
    array_short=${array_short[$i]}
    DATA_DIR=/n/holylfs05/LABS/kraft_lab/Lab/combined/TopMed_r2/${array}
    echo ${array}
    # cut -f3,4 /n/netscratch/liang_lab/Lab/btruong/EPI293_GeneticData/hpfs_df_newID_${array_short}.txt > /n/netscratch/liang_lab/Lab/btruong/EPI293_GeneticData/hpfs_df_newID_${array_short}_keep.txt

    sbatch \
        -J vcf_conversion_${array} \
        --mem=16G \
        -c 2 \
        --account=liang_lab \
        -p serial_requeue,hsph,sapphire,shared \
        --requeue \
        --array=1-22 \
        -t 0-0:30 \
        --export=DATA_DIR=${DATA_DIR},array=${array},array_short=${array_short} \
        /n/holylfs05/LABS/liang_lab/Lab/btruong/Projects/EPI293/scripts/pgen_conversion.sh

done


for array in ${array_topmed}; do

    array="AffymetrixData"
    DATA_DIR=/n/holylfs05/LABS/kraft_lab/Lab/combined/TopMed_r2/${array}

    sbatch \
        -J bgen_conversion_${array} \
        --mem=16G \
        -c 2 \
        --account=liang_lab \
        -p serial_requeue,hsph,sapphire,shared \
        --requeue \
        --array=1-22 \
        -t 0-0:30 \
        --export=DATA_DIR=${DATA_DIR},array=${array} \
        /n/holylfs05/LABS/liang_lab/Lab/btruong/Projects/EPI293/scripts/bgen_conversion.sh
done

DATA_DIR=/n/holylfs05/LABS/kraft_lab/Lab/combined/TopMed_r2/AffymetrixData


sbatch \
    -J bgen_conversion \
    --mem=16G \
    -c 2 \
    --account=liang_lab \
    -p serial_requeue,hsph,sapphire,shared \
    --requeue \
    --array=1-22 \
    -t 0-0:30 \
    --export=DATA_DIR=${DATA_DIR} \
    /n/holylfs05/LABS/liang_lab/Lab/btruong/Projects/EPI293/scripts/bgen_conversion.sh

########################


cd /n/netscratch/liang_lab/Lab/btruong/EPI293_GeneticData

wget https://cnsgenomics.com/data/t2d/Xue_et_al_T2D_META_Nat_Commun_2018.gz

mkdir -p genotype_bed

awk '{print $1,$2,"0",$2}' /n/holylfs05/LABS/kraft_lab/Lab/combined/1000GP_phase3_v5_05_2013/AffymetrixData/genotyped_affy_studies.fam > genotyped_affy_studies_fid0.txt

plink2 \
    --bfile /n/holylfs05/LABS/kraft_lab/Lab/combined/1000GP_phase3_v5_05_2013/AffymetrixData/genotyped_affy_studies \
    --update-ids genotyped_affy_studies_fid0.txt \
    --make-bed \
    --out genotype_bed/genotyped_affy_studies_fid0

plink2 \
    --bfile genotype_bed/genotyped_affy_studies_fid0 \
    --keep /n/netscratch/liang_lab/Lab/btruong/EPI293_GeneticData/hpfs_df.txt \
    --make-bed \
    --out genotype_bed/genotyped_affy_hpfs_tmp

plink2 \
    --bfile genotype_bed/genotyped_affy_hpfs_tmp \
    --update-ids /n/netscratch/liang_lab/Lab/btruong/EPI293_GeneticData/hpfs_df_newID.txt \
    --make-bed \
    --out genotype_bed/genotyped_affy_hpfs

rm -rf genotype_bed/genotyped_affy_hpfs_tmp.*



########################


# The specified private key has an invalid format and cannot be used.
# Trying rsync without the -i key argument (using default ssh keys):
rsync -avz /n/netscratch/liang_lab/Lab/btruong/EPI293_GeneticData/bed/chr19.log but714@10.37.33.138:/shared/home/but714/165993/epi293/Lab1

# If you must use a key, ensure it is a valid private key file. You can also try using ssh-agent to load your key:
eval "$(ssh-agent -s)"
ssh-add /n/holylfs05/LABS/liang_lab/Lab/btruong/Projects/EPI293/id_rsa
# Then rerun rsync without specifying -i:
rsync -avz /n/netscratch/liang_lab/Lab/btruong/EPI293_GeneticData/bed/chr5.log but714@10.37.33.138:/shared/home/but714/165993/epi293/Lab1

find /n/netscratch/liang_lab/Lab/btruong/EPI293_GeneticData/ -type f -maxdepth 3 | \
  parallel -j 16 "rsync -avz {} but714@10.37.33.138:/shared/home/but714/165993/epi293/Lab1/EPI293_GeneticData/"


###################

# Create conda environment for EPI293
mamba create -p /n/holystore01/LABS/price_lab/Lab/btruong/conda_env/epi293 r-base -y

# Activate the conda environment with a shorter alias
# You can add this to your .bashrc to create a shorter reference:
# alias epi293='conda activate /n/holystore01/LABS/price_lab/Lab/btruong/conda_env/epi293'

# Or create a symlink for easier access:
# ln -s /n/holystore01/LABS/price_lab/Lab/btruong/conda_env/epi293 ~/envs/epi293
# Then activate with: conda activate ~/envs/epi293

conda activate /n/holystore01/LABS/price_lab/Lab/btruong/conda_env/epi293

#################### RUN RVTEST #################### 
# ${MY_WORKING_DIR}/rvtest.sh


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

RVTEST_OUTPUT_PREFIX=rvtest/rvtest_chr${chr}

/n/holylfs05/LABS/liang_lab/Lab/btruong/Tools/executable/rvtest \
    --inBgen bgen/chr${chr}.bgen \
    --pheno hpfs_pheno_rvtest.txt \
    --out ${RVTEST_OUTPUT_PREFIX} \
    --single wald,score


###################



MY_WORKING_DIR=/n/netscratch/liang_lab/Lab/btruong/EPI293_GeneticData/
mkdir -p ${MY_WORKING_DIR}/log_files

sbatch \
    -J rvtest \
    --chdir ${MY_WORKING_DIR}/log_files \
    --mem=8G \
    --array=1-22 \
    -t 00-1:30 \
    --export=ALL,MY_WORKING_DIR=${MY_WORKING_DIR} \
    ${MY_WORKING_DIR}/rvtest.sh




##############################

rsync -avz /n/netscratch/liang_lab/Lab/btruong/EPI293_GeneticData/epi293_environment.yml but714@10.37.33.138:/shared/home/but714/165993/epi293/Lab1/


# Set up passwordless SSH for but714@10.37.33.138
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa_epi293 -N ""
ssh-copy-id but714@10.37.33.138

chmod 600 ~/.ssh/id_rsa_epi293
chmod 644 ~/.ssh/id_rsa_epi293.pub





#################### EXPORT CONDA ENVIRONMENT TO YML ####################

cd /n/netscratch/liang_lab/Lab/btruong/EPI293_GeneticData

conda activate /n/holystore01/LABS/price_lab/Lab/btruong/conda_env/epi293

# Alternatively, export without build strings for better cross-platform compatibility
conda env export --no-builds | grep -v "^prefix:" > epi293_environment.yml

# To install on another machine, run:

mkdir -p ~/miniconda3
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda3/miniconda.sh
bash ~/miniconda3/miniconda.sh -b -u -p ~/miniconda3
rm ~/miniconda3/miniconda.sh

conda env create -f epi293_environment.yml


rsync -avz -e ssh /n/netscratch/liang_lab/Lab/btruong/EPI293_GeneticData/bed/* but714@10.37.33.138:/shared/home/but714/165993/epi293/EPI293_GeneticData/


eval "$(ssh-agent -s)"
chmod 600 ~/.ssh/id_rsa_epi293
chmod 644 ~/.ssh/id_rsa_epi293.pub
ssh-add ~/.ssh/id_rsa_epi293

rsync -avz /n/netscratch/liang_lab/Lab/btruong/EPI293_GeneticData/bed/* but714@10.37.33.254:/shared/home/but714/165993/epi293/EPI293_GeneticData/

rsync -avz /n/netscratch/liang_lab/Lab/btruong/EPI293_GeneticData/bed/* but714@10.37.33.254:/shared/home/but714/165993/epi293/EPI293_GeneticData/


find /n/netscratch/liang_lab/Lab/btruong/EPI293_GeneticData/bed/ -type f -maxdepth 3 | \
  parallel -j 16 "rsync -avz {} but714@10.37.33.254:/shared/home/but714/165993/epi293/EPI293_GeneticData/"

rsync -avz /n/netscratch/liang_lab/Lab/btruong/EPI293_GeneticData/bed/*log but714@10.37.33.254:/shared/home/but714/165993/epi293/EPI293_GeneticData/




# Set up passwordless SSH 
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa_epi293 -N ""
ssh-copy-id -f -i ~/.ssh/id_rsa_epi293.pub but714@10.37.33.254

# Add the key to ssh-agent
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_rsa_epi293





# Set up passwordless SSH 
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa_epi293 -N ""
ssh-copy-id -f -i ~/.ssh/id_rsa_epi293.pub username@ip_address

# Add the key to ssh-agent
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_rsa_epi293