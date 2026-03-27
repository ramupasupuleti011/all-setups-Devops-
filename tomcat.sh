#!/bin/bash
set -e

echo "===== Updating system ====="
sudo dnf update -y

echo "===== Installing Java ====="
sudo dnf install -y java-11-amazon-corretto wget tar

echo "===== Creating tomcat user ====="
if id "tomcat" &>/dev/null; then
    echo "Tomcat user exists"
else
    sudo useradd -m -d /opt/tomcat -s /bin/false tomcat
fi

echo "===== Downloading Tomcat (stable archive link) ====="
cd /opt
sudo wget -q https://archive.apache.org/dist/tomcat/tomcat-9/v9.0.87/bin/apache-tomcat-9.0.87.tar.gz -O tomcat.tar.gz

echo "===== Extracting ====="
sudo tar -xzf tomcat.tar.gz
sudo mv apache-tomcat-9.0.87 tomcat

echo "===== Setting permissions ====="
sudo chown -R tomcat:tomcat /opt/tomcat
sudo chmod -R 755 /opt/tomcat

echo "===== Configuring Tomcat users ====="
sudo tee /opt/tomcat/conf/tomcat-users.xml > /dev/null <<EOF
<tomcat-users>
  <role rolename="manager-gui"/>
  <role rolename="manager-script"/>
  <user username="tomcat" password="ramu123" roles="manager-gui,manager-script"/>
</tomcat-users>
EOF

echo "===== Enabling remote access (manager app) ====="
sudo sed -i '/RemoteAddrValve/d' /opt/tomcat/webapps/manager/META-INF/context.xml
sudo sed -i '/RemoteAddrValve/d' /opt/tomcat/webapps/host-manager/META-INF/context.xml

echo "===== Starting Tomcat ====="
sudo su -s /bin/bash tomcat -c "/opt/tomcat/bin/startup.sh"

echo "===== Waiting for startup ====="
sleep 10

echo "===== Verifying Tomcat ====="
ps -ef | grep tomcat | grep -v grep

echo "===== SUCCESS ====="
echo "Open in browser:"
echo "http://<EC2-PUBLIC-IP>:8080"
echo "Manager:"
echo "http://<EC2-PUBLIC-IP>:8080/manager/html"
echo "Login: tomcat / ramu123"
