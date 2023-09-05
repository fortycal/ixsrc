#!/bin/bash

#
# Configure logging for PACS services.
#
# Run this script as the root user (e.g. use the 'sudo su -' command) 
# from the directory containing this file.
#

# Create a separate location for our logs
DIR=/var/log/idexx-pacs
if [ -d "$DIR" ]; then
    echo "$DIR exists, skipping creation."
else 
    echo "$DIR does not exist and will be created."
    mkdir $DIR
    chown syslog:adm $DIR
    chmod 775 $DIR
fi

# Log PACS services to the location above
FILE=/etc/rsyslog.d/40-idexx-pacs.conf
if [ -f "$FILE" ]; then
    echo "$FILE exists, skipping creation."
else 
    echo "$FILE does not exist and will be created."
    cp ./40-idexx-pacs.conf /etc/rsyslog.d/.
    chown root:root /etc/rsyslog.d/40-idexx-pacs.conf
fi

# Configure file rotation/retention for our logs
FILE=/etc/logrotate.d/idexx-pacs
if [ -f "$FILE" ]; then
    echo "$FILE exists, skipping creation."
else 
    echo "$FILE does not exist and will be created."
    cp ./idexx-pacs /etc/logrotate.d/.
    chown root:root /etc/logrotate.d/idexx-pacs
fi

# Tell rsyslogd to forward to log aggregator on port 514
FILE=/etc/rsyslog.conf
if grep -q "*.* @@127.0.0.1:514" "$FILE"; then
    echo "Syslog forwarding to port 514 appears to have been configured; skipping."
else
    echo "Enabling syslog forwarding to port 514 (TCP)."
    printf "\n# Enable sending of logs over TCP:" >> $FILE
    printf "\n*.* @@127.0.0.1:514\n\n" >> $FILE
fi

# Restart rsyslogd
echo "Restarting rsyslog..."
systemctl restart rsyslog
echo "Done."
