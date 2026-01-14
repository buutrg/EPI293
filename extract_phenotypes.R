
# HPFS are all male

library(data.table)
library(dplyr)
# library(venn)
options(datatable.fread.datatable=FALSE)

setwd("/n/holylfs05/LABS/liang_lab/Projects/EPI293")

# load("Data_For_Use.RData")
# load("Phenotype_For_Use.Rdata")

# fam_df = fread("/n/netscratch/liang_lab/Lab/btruong/EPI293_GeneticData/bed/chr17.fam")
pheno_df = fread("hpfs_pheno.csv")
met_df = fread("hpfs_met.csv")

white_ids = pheno_df %>% filter(racewhite == 1) %>% pull(id)

##############################

meta_dir = "/n/holylfs05/LABS/kraft_lab/Lab/combined/1000GP_phase3_v5_05_2013/AffymetrixData"

# id_mapping = fread(paste0(meta_dir, "/IDs_Mapping_Affy_Studies.txt"))
# hpfs_ids = fread(paste0(meta_dir, "/HPFS_IDs_Mapping_Affy_Studies.txt"))
all_platforms = c("Affy", "GSAD", "Omni", "Core", "Illu", "Onco")

hpfs_ids = lapply(all_platforms, function(platform) {
    df = fread(paste0("/n/holylfs05/LABS/liang_lab/Lab/xingyan/Share/Liming/HPFS_EPI293/ID_files/ID_list_use_", platform, ".csv"))
    df = df %>%
        mutate(platform = platform) %>%
        filter(cohort == "hpfs")
    return(df)
})
names(hpfs_ids) = all_platforms

hpfs_ids = do.call(rbind, hpfs_ids)
dim(hpfs_ids)

# hpfs_ids = fread("/n/holylfs05/LABS/liang_lab/Lab/xingyan/Share/Liming/HPFS_EPI293/ID_files/ID_list_use_Affy.csv")
# # nhs_ids = fread(paste0(meta_dir, "/NHS_IDs_Mapping_Affy_Studies.txt"))

# table(hpfs_ids$cohort)
# hpfs_ids = hpfs_ids %>%
#     filter(cohort == "hpfs")


# length(intersect(hpfs_ids$id, fam_df$V2))

hpfs_ids = hpfs_ids %>%
    mutate(newID = paste0(IID, "_", platform))

hpfs_df = hpfs_ids %>% 
    mutate(FID = 0) %>%
    select(FID, IID, platform) %>%
    arrange(platform, IID)

hpfs_df_newID = hpfs_df %>%
    mutate(FID1 = 0, IID1 = 1:nrow(hpfs_df))

for (platform_i in all_platforms) {
    hpfs_df_platform = hpfs_df %>%
        filter(platform == platform_i) %>%
        select(-platform)
    fwrite(hpfs_df_platform, paste0("/n/netscratch/liang_lab/Lab/btruong/EPI293_GeneticData/hpfs_df_", platform_i, ".txt"), sep = "\t", quote = FALSE, row.names = FALSE, col.names = FALSE)
    hpfs_df_newID_platform = hpfs_df_newID %>%
        filter(platform == platform_i) %>%
        select(-platform)
    fwrite(hpfs_df_newID_platform, paste0("/n/netscratch/liang_lab/Lab/btruong/EPI293_GeneticData/hpfs_df_newID_", platform_i, ".txt"), sep = "\t", quote = FALSE, row.names = FALSE, col.names = FALSE)
    print(dim(hpfs_df_newID_platform))
    print(length(unique(hpfs_df_newID_platform$IID)))
}

fwrite(hpfs_df, "/n/netscratch/liang_lab/Lab/btruong/EPI293_GeneticData/hpfs_df.txt", sep = "\t", quote = FALSE, row.names = FALSE, col.names = FALSE)
fwrite(hpfs_df_newID, "/n/netscratch/liang_lab/Lab/btruong/EPI293_GeneticData/hpfs_df_newID.txt", sep = "\t", quote = FALSE, row.names = FALSE, col.names = FALSE)

# # Plot a Venn diagram of genotype, phenotype, and metabolite IDs
# # Shows the number of overlapping IDs between each set
# venn_data <- list(
#   genotype = hpfs_ids$id,
#   phenotype = pheno_df$id,
#   metabolite = met_df$id
# )

# genotype_labs = paste0("Genotype (", length(hpfs_ids$id), ")")
# phenotype_labs = paste0("Phenotype (", length(pheno_df$id), ")")
# metabolite_labs = paste0("Metabolite (", length(met_df$id), ")")
# names(venn_data) <- c(genotype_labs, phenotype_labs, metabolite_labs)

# pdf("venn_diagram.pdf")
# venn(
#   venn_data,
#   zcolor = "style",
#   counts = TRUE
# )
# dev.off()

########################

hpfs_df_newID = fread("/n/netscratch/liang_lab/Lab/btruong/EPI293_GeneticData/hpfs_df_newID.txt")
# hpfs_df_newID = hpfs_df_newID[,c(2,5)]
# colnames(hpfs_df_newID) = c("IID_old", "IID_new")

colnames(hpfs_df_newID)[c(2, 3, 5)] = c("IID_old", "platform", "IID_new")

hpfs_df_newID = hpfs_df_newID %>%
    mutate(newID = paste0(IID_old, "_", platform))

hpfs_df_newID = hpfs_df_newID %>%
    mutate(studyID = hpfs_ids$id[match(newID, hpfs_ids$newID)])

met_df_1 = met_df %>%
    filter(!duplicated(id))
dim(met_df_1)

all_df = merge(hpfs_df_newID, pheno_df, by.x = "studyID", by.y = "id", all.x = TRUE)
all_df = merge(all_df, met_df_1 %>% select(-intersect(colnames(all_df), colnames(met_df))), by.x = "studyID", by.y = "id", all.x = TRUE)
# all_df = merge(all_df, hpfs_ids, by.x = "IID_old", by.y = "IID", all.x = TRUE)

# length(intersect(all_df$newID, hpfs_ids$newID))
all_df = merge(all_df, hpfs_ids, by = "newID", all.x = TRUE)

fwrite(all_df, "/n/netscratch/liang_lab/Lab/btruong/EPI293_GeneticData/hpfs_pheno_met.csv", sep = ",", quote = FALSE, row.names = FALSE)

##########################

all_df = fread("/n/netscratch/liang_lab/Lab/btruong/EPI293_GeneticData/hpfs_pheno_met.csv")
colnames(all_df)

covar_df = all_df %>%
    mutate(FID = 0) %>%
    select(FID, IID_new, ageyr, diabetes, BMIcont, WHRcont, PC1, PC2, PC3, PC4, PC5, PC6, PC7, PC8, PC9, PC10)
colnames(covar_df) = c("FID", "IID", "ageyr", "t2d", "bmi", "whr", "PC1", "PC2", "PC3", "PC4", "PC5", "PC6", "PC7", "PC8", "PC9", "PC10")

head(covar_df)
dim(covar_df)
summary(covar_df)

fwrite(covar_df, "/n/netscratch/liang_lab/Lab/btruong/EPI293_GeneticData/hpfs_pheno_covar.txt", sep = "\t", quote = FALSE, row.names = FALSE, na=NA)
summary(covar_df$bmi)

##########################

covar_df = fread("/n/netscratch/liang_lab/Lab/btruong/EPI293_GeneticData/hpfs_pheno_covar.txt")

pdf("bmi_hist.pdf")
hist(covar_df$bmi, breaks = 100)
dev.off()

tmp = covar_df %>%
    mutate(fatid = 0, matid = 0, sex=1) %>%
    mutate(t2d = ifelse(t2d == 1, 2, 1)) %>%
    select(FID, IID, fatid, matid, sex, t2d, bmi)

colnames(tmp) = c("fid", "iid", "fatid", "matid", "sex", "t2d", "bmi")


fwrite(tmp, "/n/netscratch/liang_lab/Lab/btruong/EPI293_GeneticData/hpfs_pheno_rvtest.txt", sep = "\t", quote = FALSE, row.names = FALSE)

