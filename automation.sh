#! /bin/bash

sudo apt update -y

status=$(dpkg --get-selections | grep apache)
status2=$(service apache2 status)

if [[ $status == *"apache2"* ]]; then
   echo "apache2 is installed"
else sudo apt install apache2
fi

if [[ $status2 == *"active (running)"* ]]; then
  echo "process is running"
else systemctl start apache2
fi


cd /var/log/apache2

timestamp=$(date '+%d%m%Y-%H%M%S')

tar -cvf shyamp-httpd-logs-${timestamp}.tar *.log

cp shyamp-httpd-logs-${timestamp}.tar /tmp/.

aws s3 cp /tmp/shyamp-httpd-logs-${timestamp}.tar s3://upgrad-shyamp/shyamp-httpd-logs-${timestamp}.tar

filepath="/tmp/shyamp-httpd-logs-${timestamp}.tar"
size=$( stat -c %s $filepath)
if test -f "/var/www/html/inventory.html"; then
   echo "inventory file exists"
else echo "Logtype        datecreated        type       size" >> /var/www/html/inventory.html
fi

echo "httpd-logs	$timestamp	  tar	    $size" >> /var/www/html/inventory.html

if test -f "/etc/cron.d/automation"; then
   echo "cronfile exists"
else echo "0 1 * * * root /root/Automation_project/Automation_project/automation.sh" > /etc/cron.d/automation
fi
