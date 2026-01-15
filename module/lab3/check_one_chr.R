
library(data.table)
library(dplyr)

options(datatable.fread.datatable=FALSE)

# Read in the meta-analysis results for chromosome 16
df = fread("~/lab3/meta_analysis_chr16_bmi_results1.txt")

# Print the number of rows in the data frame
message(paste0("Number of rows: ", nrow(df)))

df = df %>%
    arrange(`P-value`) # sort by P-value from smallest to largest

# Print the head of the data frame
head(df)
