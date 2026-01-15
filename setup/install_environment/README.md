# Installing the EPI 293 Environment

This guide walks you through setting up the conda environment for EPI 293.

## Steps

### 1. Download and Install Miniconda

```bash
mkdir -p ~/miniconda3
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda3/miniconda.sh
bash ~/miniconda3/miniconda.sh -b -u -p ~/miniconda3
rm ~/miniconda3/miniconda.sh
```

### 2. Request a Compute Node

Request a small interactive node to install the environment:

```bash
srun --pty -p general -t 0-6:00 --mem 8G /bin/bash
```

### 3. Activate and Initialize Conda

```bash
source ~/miniconda3/bin/activate
conda init --all
```

### 4. Create the Conda Environments

Use the environment file included in this folder:

```bash
conda env create -f epi293_environment.yml
```

For the genomicsem environment (path will be provided in class):

```bash
conda env create -f <path_to_course_data>/genomicsem.env.yml
```

### 5. Activate the Environment

```bash
conda activate epi293
```

### 6. Verify Installation

Run the following commands and provide the output in the Google Form:

```bash
which regenie
which plink2
which plink
which R
```

## Troubleshooting

If you encounter any issues during installation, please reach out to the course instructors.
