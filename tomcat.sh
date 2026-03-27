#!/bin/bash

# Exit on error
set -e

echo "Updating system..."
if command -v dnf >/dev/null 2>&1; then
    sudo dnf update -y
    sudo dnf install java-17-amazon-corretto wget unzip -y
else
    sudo yum update -y
    sudo yum install java-17-openjdk wget unzip -y
fi

echo "Installing PostgreSQL..."
if command -v dnf >/dev/null 2>&1; then
    sudo dnf install postgresql15-server postgresql15 -y
    sudo postgresql-setup --initdb
else
    sudo amazon-linux-extras enable postgresql14
    sudo yum install postgresql-server postgresql-contrib -y
    sudo postgresql-setup initdb
fi

sudo systemctl start postgresql
sudo systemctl enable postgresql

echo "Setting up SonarQube database..."
sudo -u postgres psql <<EOF
CREATE USER sonar WITH ENCRYPTED PASSWORD 'sonar';
CREATE DATABASE sonarqube OWNER sonar;
GRANT ALL PRIVILEGES ON DATABASE sonarqube TO sonar;
EOF

echo "Creating sonar user..."
sudo useradd sonar || true
sudo mkdir -p /opt/sonarqube

echo "Downloading SonarQube..."
cd /opt
sudo wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-9.9.3.79811.zip
sudo unzip sonarqube-9.9.3.79811.zip
sudo mv sonarqube-9.9.3.79811 sonarqube
sudo chown -R sonar:sonar /opt/sonarqube

echo "Configuring SonarQube..."
sudo bash -c 'cat > /opt/sonarqube/conf/sonar.properties <<EOL
sonar.jdbc.username=sonar
sonar.jdbc.password=sonar
sonar.jdbc.url=jdbc:postgresql://localhost:5432/sonarqube
sonar.web.host=0.0.0.0
sonar.web.port=9000
EOL'

echo "Updating system limits..."
sudo bash -c 'cat >> /etc/sysctl.conf <<EOL
vm.max_map_count=262144
fs.file-max=65536
EOL'

sudo sysctl -p

echo "Starting SonarQube..."
sudo su - sonar -c "/opt/sonarqube/bin/linux-x86-64/sonar.sh start"

echo "======================================"
echo "SonarQube installed successfully!"
echo "Access URL: http://<EC2-PUBLIC-IP>:9000"
echo "Default login: admin / admin"
echo "======================================"
