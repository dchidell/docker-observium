#!/bin/bash

echo "Starting core services..."
service mysql start
apache2ctl restart
service cron restart
cat /opt/hosts >> /etc/hosts

if [ -d "/opt/observium" ]; then
 echo "Observium directory found! Attempting upgrade..."
 cd /opt
 echo "Backing up old install..."
 mv observium observium_old
 tar -cvf observium_old.tar observium_old/
 echo "Downloading the latest version..."
 wget -Oobservium-community-latest.tar.gz http://www.observium.org/observium-community-latest.tar.gz
 tar zxvf observium-community-latest.tar.gz
 echo "Migrating directories..."
 mv /opt/observium_old/rrd observium/
 mv /opt/observium_old/*log* observium/
 mv /opt/observium_old/config.php observium/
 echo "Running update scripts..."
 /opt/observium/discovery.php -u
 /opt/observium/discovery.php -h all
 echo "Cleaning up..."
 rm observium-community-latest.tar.gz
 rm -rf /opt/observium_old/
 apache2ctl restart
else
 echo "No observium found! Attempting download..."
 mkdir -p /opt/observium && cd /opt
 echo "Downloading the latest version..."
 wget http://www.observium.org/observium-community-latest.tar.gz
 tar zxvf observium-community-latest.tar.gz
 echo "Cleaning and configuring..."
 rm observium-community-latest.tar.gz
 cd observium/
 cp config.php.default config.php
 sed -i 's/USERNAME/observium/g' config.php
 sed -i 's/PASSWORD/'"$OBSERVIUM_PW"'/g' config.php
 mkdir logs
 mkdir rrd
 chown www-data:www-data rrd
 echo "Running initial database scripts..."
 /opt/observium/discovery.php -u
 echo "Adding default user: admin/password"
 /opt/observium/adduser.php admin password 10
 apache2ctl restart
fi

echo "Observium is running! This container will stop when apache dies (within 1 minute)."
while ps axg | grep -vw grep | grep -w apache2 > /dev/null; do sleep 60; done
