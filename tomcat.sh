#!/bin/bash
set -e

echo "===== Detecting OS ====="
if [ -f /etc/os-release ]; then
    . /etc/os-release
fi

echo "OS: $NAME"

echo "===== Installing Java & tools ====="

if [[ "$NAME" == *"Amazon Linux"* ]]; then
    if command -v dnf &> /dev/null; then
        sudo dnf install -y java-11-amazon-corretto wget tar
    else
        sudo yum install -y java-11-amazon-corretto wget tar
    fi

elif [[ "$NAME" == *"Ubuntu"* ]]; then
    sudo apt update -y
    sudo apt install -y openjdk-11-jdk wget tar
else
    echo "Unknown OS, trying generic install"
    sudo yum install -y java-11-openjdk wget tar || sudo apt install -y openjdk-11-jdk wget tar
fi

echo "===== Creating tomcat user ====="
id tomcat &>/dev/null || sudo useradd -m -d /opt/tomcat -s /bin/false tomcat

echo "===== Downloading Tomcat (no 404) ====="
cd /opt
sudo wget -q https://archive.apache.org/dist/tomcat/tomcat-9/v9.0.87/bin/apache-tomcat-9.0.87.tar.gz -O tomcat.tar.gz

echo "===== Extracting ====="
sudo tar -xzf tomcat.tar.gz
sudo mv apache-tomcat-9.0.87 tomcat

echo "===== Setting permissions ====="
sudo chown -R tomcat:tomcat /opt/tomcat
sudo chmod -R 755 /opt/tomcat

echo "===== Configuring users ====="
sudo tee /opt/tomcat/conf/tomcat-users.xml > /dev/null <<EOF
<tomcat-users>
  <role rolename="manager-gui"/>
  <role rolename="manager-script"/>
  <user username="tomcat" password="ramu123" roles="manager-gui,manager-script"/>
</tomcat-users>
EOF

echo "===== Enabling manager access ====="
sudo sed -i '/RemoteAddrValve/d' /opt/tomcat/webapps/manager/META-INF/context.xml
sudo sed -i '/RemoteAddrValve/d' /opt/tomcat/webapps/host-manager/META-INF/context.xml

echo "===== Starting Tomcat ====="
sudo su -s /bin/bash tomcat -c "/opt/tomcat/bin/startup.sh"

sleep 10

echo "===== SUCCESS ====="
echo "Tomcat URL: http://<EC2-PUBLIC-IP>:8080"
echo "Manager URL: http://<EC2-PUBLIC-IP>:8080/manager/html"
echo "Login: tomcat / ramu123"
