# EPI 293 - Lab Modules

This folder contains lab scripts for EPI 293.

## Lab 3: GWAS and Meta-Analysis with REGENIE

**Files:**
- `EPI293_Lab3.sh` - Main lab script (REGENIE + METAL)
- `combine_regenie.R` - R script to combine REGENIE results and generate Manhattan plot

### Overview

This lab covers:
- Running GWAS using REGENIE (two-step approach)
- Meta-analysis using METAL
- Combining results and visualization

### Topics Covered

1. **REGENIE Step 1** - Fit the whole genome regression model
2. **REGENIE Step 2** - Test associations at each variant
3. **Meta-analysis with METAL** - Combine results across genotyping platforms

### Computational Requirements

- **Memory:** 8GB RAM
- **Cores:** 4
- **Time:** ~1-2 hours per step

### Key Commands

#### Request an interactive node:
```bash
srun --pty -p general -t 0-6:00 --mem 8G -c 4 /bin/bash
```

#### Activate environment:
```bash
conda activate epi293
```

### Genotyping Platforms Analyzed

| Platform | Abbreviation |
|----------|--------------|
| AffymetrixData | Affy |
| GlobalScreeningArrayData | GSAD |
| HumanCoreExData2 | Core |
| IlluminaHumanHapData | Illu |
| OmniExpressData | Omni |
| OncoArrayData | Onco |

### Output

- REGENIE association results (`.regenie` files)
- Meta-analysis results from METAL

### Notes

- For **quantitative traits**: use `--apply-rint` flag
- For **binary traits**: replace `--apply-rint` with `--bt --firth --approx`

### Troubleshooting

#### R Library Issues

If you encounter problems loading R libraries, add the following line at the beginning of your R script:

```r
.libPaths("~/miniconda3/envs/epi293/lib/R/library")
```

This ensures R can find the libraries installed in the conda environment.

### Resources

- [REGENIE Documentation](https://rgcgithub.github.io/regenie/)
- [METAL Documentation](https://genome.sph.umich.edu/wiki/METAL_Documentation)
