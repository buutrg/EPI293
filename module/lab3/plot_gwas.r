library(fastman)
library(data.table)

options(datatable.fread.datatable=FALSE)

all_df = fread("~/lab3/meta_analysis_chrall_bmi_results1.txt")

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
