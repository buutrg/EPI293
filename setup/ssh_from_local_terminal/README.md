# EPI 293 - Code Materials

This repository contains code materials and scripts for **EPI 293** at Harvard.

## Getting Started

### Logging into Open OnDemand (OOD)

Follow the instructions in `login_ood.sh` to set up passwordless SSH access to the computing cluster.

#### Prerequisites
- VPN connection (if required)
- HarvardKey credentials

#### Steps

1. **Generate an SSH key pair:**
   ```bash
   ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa_epi293 -N ""
   ```

2. **Copy your public key to the server:**
   ```bash
   ssh-copy-id -f -i ~/.ssh/id_rsa_epi293.pub username@ip_address
   ```
   Replace `username` with your Harvard username and `ip_address` with the server address provided in class.

3. **Add the key to your SSH agent:**
   ```bash
   eval "$(ssh-agent -s)"
   ssh-add ~/.ssh/id_rsa_epi293
   ```

4. **Connect to the server:**
   ```bash
   ssh username@ip_address
   ```

## Contents

| File | Description |
|------|-------------|
| `login_ood.sh` | SSH setup script for OOD access |

## Questions?

If you encounter any issues, please reach out to the course instructors.
