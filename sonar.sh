#!/bin/bash
set -e

echo "===== Installing dependencies ====="
sudo dnf install -y java-11-amazon-corretto unzip wget

echo "===== Creating sonar user ====="
id sonar || sudo useradd sonar

echo "===== Downloading SonarQube ====="
cd /opt
sudo wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-8.9.6.50800.zip -O sonarqube.zip

echo "===== Extracting ====="
sudo unzip sonarqube.zip
sudo mv sonarqube-8.9.6.50800 sonarqube

echo "===== Setting permissions ====="
sudo chown -R sonar:sonar /opt/sonarqube

echo "===== Kernel settings ====="
sudo sysctl -w vm.max_map_count=262144
sudo sysctl -w fs.file-max=65536

echo "===== Starting SonarQube ====="
sudo su - sonar -c "/opt/sonarqube/bin/linux-x86-64/sonar.sh start"

echo "===== Waiting ====="
sleep 25

echo "===== Status ====="
sudo su - sonar -c "/opt/sonarqube/bin/linux-x86-64/sonar.sh status"

echo "===== DONE ====="
echo "Open: http://<EC2-IP>:9000"
echo "Login: admin / admin"
