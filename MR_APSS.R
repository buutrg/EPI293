
# Install MR-APSS if not already installed
# devtools::install_github("YangLabHKUST/MR-APSS") # If prompted, choose "None" or "n" to proceed

library(MRAPSS)
library(dplyr)
library(data.table)
options(datatable.fread.datatable=FALSE)

setwd("/n/netscratch/liang_lab/Lab/btruong/EPI293_GeneticData")

# Load GWAS summary statistics
# Exposure GWAS (e.g., BMI)
exposure_file = "/n/netscratch/liang_lab/Lab/btruong/EPI293_GeneticData/step2/hpfs_bmi_step2_chrall_bmi.regenie"
exposure_df = fread(exposure_file)

mapping_df = fread("/n/holylfs05/LABS/liang_lab/Lab/btruong/Tools/w_hm3_snpID_hg38.snplist", header=F)
colnames(mapping_df) = c("SNP_hg19", "ID")

exposure_df1 = merge(exposure_df, mapping_df, by = "ID")

# Remove duplicate SNPs
exposure_df1 = exposure_df1[!duplicated(exposure_df1$SNP_hg19),]

# Check how many SNPs are in the mapped file
dim(exposure_df1)

# Standardize column names for MR-APSS
exposure_dat = format_data(
    exposure_df1,
    snp_col = "SNP_hg19",
    freq_col = "A1FREQ",
    A1_col = "ALLELE1",
    A2_col = "ALLELE0",
    b_col = "BETA",
    se_col = "SE",
    p_col = "P",
    n_col = "N"
)

# Load outcome GWAS summary statistics
outcome_file = "/n/netscratch/liang_lab/Lab/btruong/EPI293_GeneticData/Xue_et_al_T2D_META_Nat_Commun_2018.gz"
outcome_df = fread(outcome_file)

outcome_dat = format_data(
    outcome_df,
    snp_col = "SNP",
    freq_col = "frq_A1",
    b_col = "b",
    se_col = "se",
    p_col = "P",
    n_col = "N"
)

head(outcome_dat)

###################

paras = est_paras(
    dat1 = exposure_dat,
    dat2 = outcome_dat,
    trait1.name = "BMI",
    trait2.name = "T2D",
    ldscore.dir = "/n/holylfs05/LABS/liang_lab/Lab/btruong/Tools/eur_w_ld_chr"
)

paras$Omega
paras$C

head(paras$dat)

########## MR-APSS from BMI to T2D ##########

# Clump SNPs to obtain independent instruments
MRdat = clump(
    paras$dat,
    IV.Threshold = 5e-5,
    SNP_col = "SNP",
    pval_col = "pval.exp",
    clump_kb = 1000,
    clump_r2 = 0.01,
    bfile = "/n/holylfs05/LABS/liang_lab/Lab/btruong/Tools/g1000_eur",
    plink_bin = "/n/holystore01/LABS/price_lab/Lab/btruong/conda_env/epi293/bin/plink"
)
head(MRdat)

# Run MR-APSS model
mr_result = MRAPSS(
    MRdat,
    exposure = "BMI",
    outcome = "T2D",
    C = paras$C,
    Omega = paras$Omega,
    Cor.SelectionBias = T
)

########## MR-APSS from T2D to BMI ##########

MRdat_rev = clump(
    paras$dat,
    IV.Threshold = 5e-8,
    SNP_col = "SNP",
    pval_col = "pval.out",
    clump_kb = 1000,
    clump_r2 = 0.01,
    bfile = "/n/holylfs05/LABS/liang_lab/Lab/btruong/Tools/g1000_eur",
    plink_bin = "/n/holystore01/LABS/price_lab/Lab/btruong/conda_env/epi293/bin/plink"
)

# Run MR-APSS model
mr_result_rev = MRAPSS(
    MRdat_rev,
    exposure = "T2D",
    outcome = "BMI",
    C = paras$C,
    Omega = paras$Omega,
    Cor.SelectionBias = T
)
