#!/bin/sh

set -e
trap '[ $? -eq 0 ] || echo "${RED}######### SERVICE SETUP FAILED #########${NC}"' EXIT

sudo cp tomcat.service /etc/systemd/system
if test "$1" = "mysql" ; then
  sudo cp mysql.service /etc/systemd/system
  sudo sed -i -e "s|mariadb.service|mysql.service|" /etc/systemd/system/tomcat.service
else
  sudo cp mariadb.service /etc/systemd/system
fi

sudo sed -i -e "s|home_ph|$HOME/tomcat-app|" /etc/systemd/system/tomcat.service

if [ -z "$2" ] ; then
     sudo sed -i -e "s|user_ph|root|" /etc/systemd/system/tomcat.service
else
     sudo sed -i -e "s|user_ph|$2|" /etc/systemd/system/tomcat.service  # If a user is provided, replace 'user_ph' with the provided user
fi

sudo systemctl daemon-reload

if test "$1" = "mysql"  ; then
  sudo systemctl start mysql
else
  sudo systemctl start mariadb
fi

echo "${GREEN}############## Service setup completed ##############${NC}\n\n\n"