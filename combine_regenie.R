library(data.table)
library(dplyr)
library(fastman)
options(datatable.fread.datatable=FALSE)

filename = "/n/netscratch/liang_lab/Lab/btruong/EPI293_GeneticData/step2/hpfs_step2_chr@_t2d.regenie"
filename = "/n/netscratch/liang_lab/Lab/btruong/EPI293_GeneticData/step2/hpfs_bmi_step2_chr@_bmi.regenie"

for (chr in 1:22) {
    print(chr)
    filename_chr = gsub("@", chr, filename)
    df = fread(filename_chr)
    if (chr == 1) {
        all_df = df
    } else {
        all_df = rbind(all_df, df)
    }
}

filename_out = gsub("@", "all", filename)

all_df = all_df %>%
    mutate(P = 10^(-LOG10P))

fwrite(all_df, filename_out, sep = "\t", quote = FALSE, row.names = FALSE, na = NA)

###############################################

all_df = fread(filename_out)

png("manhattan_plot.png", width = 14, height = 5, units = "in", res = 300)
fastman(all_df, chr = "CHROM", bp = "GENPOS", p = "P")
dev.off()

