# Use VPN if needed
# Set up passwordless SSH, use your HarvardKey when prompted
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa_epi293 -N ""
ssh-copy-id -f -i ~/.ssh/id_rsa_epi293.pub username@ip_address

# Add the key to ssh-agent
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_rsa_epi293

# Then try to connect to the server
ssh username@ip_address
