#!/bin/bash
apt update
apt install apache2 -y
rm /var/www/html/index.html
cp /home/ubuntu/index.html /var/www/html/index.html
cp /home/ubuntu/style.css /var/www/html/style.css
