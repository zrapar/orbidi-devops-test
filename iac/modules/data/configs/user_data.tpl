#!/bin/bash
# Set the SSH password for the EC2 instance
sudo echo "${SSH_USER}:${SSH_PASSWORD}" | sudo chpasswd

# Enable password authentication for SSH
sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config

# Allow TCP forwarding
sudo sed -i 's/#AllowTcpForwarding yes/AllowTcpForwarding yes/g' /etc/ssh/sshd_config

# Restart the SSH service to apply changes
sudo service sshd restart
