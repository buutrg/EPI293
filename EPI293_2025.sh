# This script is used to run the GWAS analysis for the EPI293 course.
# Please contact Buu Truong (btruong@hsph.harvard.edu) if you have any questions.


# Please go to OOD and request Clusters -> _academic Shell Access

########### ENVIRONMENT SETUP ###########

salloc -c 4 --mem 8000 -t 0-4:00 # Request CPU and RAM 

bash ${HOME}/150583/EPI293/Tools/MiniConda3-latest-Linux-x86_64.sh # Install Miniconda
eval "$(~/miniconda3/bin/conda shell.bash hook)" 
conda init
source ~/.bashrc

conda env create -f environment.yml # Create conda environment

conda activate epi293 # Activate conda environment

########## RUN GWAS with REGENIE ##########

mkdir -p ${HOME}/log_files # Create folder to keep log files

# Make regenie variables
ARRAY_list="AffymetrixData GlobalScreeningArrayData HumanCoreExData2 IlluminaHumanHapData OmniExpressData OncoArrayData" # ARRAY list
covarColList="age86,PC1,PC2,PC3,PC4,PC5,PC6,PC7,PC8,PC9,PC10"

phenoCol=bmi86 # BMI
add_args="--qt --apply-rint"

phenoCol=diabetes # Diabetes status
add_args="--bt --firth --approx"



for ARRAY in ${ARRAY_list}; do

    wdir=${HOME}/regenie/${ARRAY}_${phenoCol}/
    mkdir -p ${wdir}
    bed=${HOME}/150583/EPI293/HPFS/genotypedata/${ARRAY}_genotyped
    phenotype=${HOME}/150583/EPI293/HPFS/phenotype/phenotype_covariates_${ARRAY}.txt

    # Run regenie step 1 
    sbatch \
        -J s1_${ARRAY}_${phenoCol} \
        --chdir ${HOME}/log_files \
        --export=ALL,wdir=${wdir},bed=${bed},phenotype=${phenotype},phenoCol=${phenoCol},ARRAY=${ARRAY} \
        ${HOME}/150583/EPI293/scripts/regenie_s1.sh ${covarColList} ${add_args}

done

# Wait until step 1 is done and then run step 2

for ARRAY in ${ARRAY_list}; do

    wdir=${HOME}/regenie/${ARRAY}_${phenoCol}/
    phenotype=${HOME}/150583/EPI293/HPFS/phenotype/phenotype_covariates_${ARRAY}.txt

    sbatch \
        -J s2_${ARRAY}_${phenoCol} \
        --chdir ${HOME}/log_files \
        --export=ALL,wdir=${wdir},phenotype=${phenotype},phenoCol=${phenoCol},ARRAY=${ARRAY} \
        --array=1-22 \
        ${HOME}/150583/EPI293/scripts/regenie_s2.sh ${covarColList} ${add_args}

done

# Combine regenie results for all chromosomes

for ARRAY in ${ARRAY_list}; do

    wdir=${HOME}/regenie/${ARRAY}_${phenoCol}/

    sbatch \
        -J c_${ARRAY}_${phenoCol} \
        --chdir ${HOME}/log_files \
        --export=ALL,wdir=${wdir},phenoCol=${phenoCol},ARRAY=${ARRAY} \
        ${HOME}/150583/EPI293/Lab4/scripts/combine_regenie.sh

done

phenoCol=bmi86 # BMI


################## RUN METAL ##################

phenoCol=diabetes # Diabetes status

wdir=${HOME}/regenie/metal_${phenoCol}/
mkdir -p ${wdir}

sbatch \
    -J metal_${phenoCol} \
    --chdir ${HOME}/log_files \
    --export=ALL,wdir${wdir},phenoCol=${phenoCol} \
    ${HOME}/150583/EPI293/Lab4/scripts/metal.sh

#############################################

### Prepare lab3 data for imputation

# Get a list of SNPs with missing rate>5%, 
awk '$5>0.05' plink.lmiss | awk '{print $2}' | grep -v SNP > bad_SNPs.txt

# Get a list of SNPs with HWE pvalue<10^-6 
grep ALL plink.hwe | grep -v nan | awk '$9<1e-6' | awk '{print $2}' >> bad_SNPs.txt

# Get a list of SNPs with MAF<0.02
awk '$5<0.02' plink.frq | awk '{print $2}' >> bad_SNPs.txt

# To see how many SNPs in each QC category
awk '$5>0.05' plink.lmiss | awk '{print $2}' | grep -v SNP | wc -l
grep ALL plink.hwe | grep -v nan | awk '$9<1e-6' | wc -l
awk '$5<0.02' plink.frq | awk '{print $2}' | wc -l

# To check the total number of unique SNPs to remove
wc -l bad_SNPs.txt
sort  bad_SNPs.txt | uniq | wc -l

# Save the list of unique SNPs to remove
sort  bad_SNPs.txt | uniq > bad_SNP_uniq.txt

# Remove the bad SNPs
plink --ped ../data/lab3.ped --map ../data/lab3.map --exclude bad_SNP_uniq.txt --make-bed --out lab3_QC

# Convert the plink file to vcf format
plink --bfile lab3_QC --recode vcf --out lab3_QC
bgzip lab3_QC.vcf
tabix -f lab3_QC.vcf.gz

# Run Eagle for pre-phasing without a reference panel
eagle \
    --vcf=lab3_QC.vcf.gz \
    --geneticMapFile=${HOME}/150583/EPI293/Tools/genetic_map_hg38_withX.txt.gz  \
    --chrom=20 \
    --outPrefix=lab3_QC_without \
    --numThreads=4 \
    --bpStart 16000000 --bpEnd 17000000 \
    2>&1 | tee lab3_QC_without.log

# Run Eagle for pre-phasing with a reference panel
eagle \
    --vcfTarget=lab3_QC.vcf.gz \
    --vcfRef=chr20.1kg.phase3.v5a.part.vcf.gz \
    --geneticMapFile=genetic_map_hg38_withX.txt.gz  \
    --chrom=20 \
    --outPrefix=lab3_QC_with \
    --numThreads=4 \
    --allowRefAltSwap \
    --bpStart 16000000 --bpEnd 17000000 \
    2>&1 | tee lab3_QC_with.log


###########

source ~/150583/EPI293/Tools/bash_epi293.sh

# Index the reference panel
tabix -f chr20.1kg.phase3.v5a.vcf.gz
bcftools view chr20.1kg.phase3.v5a.vcf.gz -r 20:16000000-17000000 > chr20.1kg.phase3.v5a.part.vcf

# Run Minimac3 to prepare data for pre-phasing and imputation
Minimac3 --refHaps chr20.1kg.phase3.v5a.part.vcf --processReference --prefix chr20.1kg.phase3.v5a.part
bgzip chr20.1kg.phase3.v5a.part.vcf
tabix -f chr20.1kg.phase3.v5a.part.vcf.gz

# Run Minimac3 to impute the data that was pre-phased without a reference panel
Minimac3-omp \
    --cpus 4 --refHaps chr20.1kg.phase3.v5a.part.m3vcf.gz \
    --format DS,GT,GP --lowMemory \
    --haps lab3_QC_without.vcf.gz\
    --prefix lab3_QC_without.imputed \
2>&1 | tee lab3_QC_without_minimac.log

# Convert to gen file
bcftools view \
    -h lab3_QC_without.imputed.dose.vcf.gz | \
    awk '{print} NR==5 {print "##FILTER=<ID=GENOTYPED>"}' | \
    bcftools reheader -h - \
        lab3_QC_without.imputed.dose.vcf.gz | \
    bcftools annotate -Ou -x ID \
        -I +'%CHROM:%POS:%REF:%ALT' | \
    bcftools convert \
        -g lab3_QC_without.imputed \
        --tag GP \
        --3N6 \
        --vcf-ids 

# Run Minimac3 to impute the data that was pre-phased with a reference panel
Minimac3-omp \
    --cpus 4 --refHaps chr20.1kg.phase3.v5a.part.m3vcf.gz \
    --format DS,GT,GP --lowMemory \
    --haps lab3_QC_with.vcf.gz\
    --prefix lab3_QC_with.imputed \
    2>&1 | tee lab3_QC_with_minimac.log

# Convert to gen file
bcftools view \
    -h lab3_QC_with.imputed.dose.vcf.gz | \
    awk '{print} NR==5 {print "##FILTER=<ID=GENOTYPED>"}' | \
    bcftools reheader -h - \
        lab3_QC_with.imputed.dose.vcf.gz | \
    bcftools annotate -Ou -x ID \
        -I +'%CHROM:%POS:%REF:%ALT' | \
    bcftools convert \
        -g lab3_QC_with.imputed \
        --tag GP \
        --3N6 \
        --vcf-ids

