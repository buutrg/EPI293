
library(data.table)
library(dplyr)

# devtools::install_github('adhikari-statgen-lab/fastman',build_vignettes = FALSE)
library(fastman)

options(datatable.fread.datatable=FALSE)

platform = "AffymetrixData"
# platform = "GlobalScreeningArrayData"
# platform = "HumanCoreExData2"
# platform = "IlluminaHumanHapData"
# platform = "OmniExpressData"
# platform = "OncoArrayData"

filename = paste0("~/lab3/platform_", platform, "/regenie/step2/hpfs_step2_chr@_bmi_withP.regenie")

# Replace @ with all to create the output filename
filename_out = gsub("@", "all", filename)

# Read in the data for each chromosome
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

# Print the head of the data frame
head(all_df)

# Print the number of rows in the data frame
message(paste0("Number of rows: ", nrow(all_df)))

# Write the data frame to a file
fwrite(all_df, filename_out, sep = "\t", quote = FALSE, row.names = FALSE, na = NA, nThread = 4)

###############################################

# Create the plots directory
dir.create(paste0("~/lab3/plots/"), showWarnings = FALSE, recursive = TRUE)

# Create the Manhattan plot
png(paste0("~/lab3/plots/", platform, "_manhattan_plot.png"), width = 14, height = 5, units = "in", res = 300)
fastman(
    all_df, 
    chr = "CHROM", bp = "GENPOS", p = "P",
    col = "greys"
)
dev.off()

# Create the QQ plot
png(paste0("~/lab3/plots/", platform, "_qq_plot.png"), width = 5, height = 5, units = "in", res = 300)
fastqq(all_df$P)
dev.off()

