#!/bin/bash

# Update system
sudo yum update -y

# Install Java 17
sudo yum install java-17-amazon-corretto -y

# Add Jenkins repository
sudo wget -O /etc/yum.repos.d/jenkins.repo \
https://pkg.jenkins.io/redhat-stable/jenkins.repo

# Import Jenkins key
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key

# Install Jenkins
sudo yum install jenkins -y

# Reload systemd
sudo systemctl daemon-reload

# Enable Jenkins at boot
sudo systemctl enable jenkins

# Start Jenkins
sudo systemctl start jenkins

# Check Jenkins status
sudo systemctl status jenkins
