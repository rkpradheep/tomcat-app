#!/bin/sh

. ./set_variables.sh

set -e
trap '[ $? -eq 0 ] || echo "${RED}######### MARIADB SETUP FAILED #########${NC}"' EXIT


########### MARIADB SETUP START ##############

if [ "$AUTO_MODE" = "false" ]; then
  echo "Do you want to setup MARIADB? (yes/no)"
  read consent

  if ! [ "$consent" = "yes" ]; then
      echo "########## MARIADB SETUP SKIPPED ##########"
      exit 0
  fi
fi

echo "############## Mariadb setup started ##############\n"

if [ -f "/etc/systemd/system/mysql.service" ]; then
  sudo systemctl stop mysql
  sudo systemctl disable mysql
fi
if [ -f "/etc/systemd/system/mariadb.service" ]; then
  sudo systemctl stop mariadb
  sudo systemctl disable mariadb
fi

if ! $(grep -q mysql /etc/passwd) ; then
    echo "Adding mysql user"
    sudo useradd mysql
fi
sudo mkdir -p /opt/mariadb
sudo rm -rf /opt/mariadb/mariadb-${MARIADB_VERSION}
#sudo wget -P /tmp https://mariadb.in.ssimn.org/mariadb-${MARIADB_VERSION_ONLY}/bintar-linux-systemd-x86_64/mariadb-${MARIADB_VERSION}.tar.gz
sudo wget -P /tmp https://dlm.mariadb.com/3906741/MariaDB/mariadb-${MARIADB_VERSION_ONLY}/bintar-linux-systemd-x86_64/mariadb-${MARIADB_VERSION}.tar.gz
if ! [ -d "/opt/mariadb" ]; then
  sudo mkdir /opt/mariadb
fi
sudo tar -xvf /tmp/mariadb-${MARIADB_VERSION}.tar.gz --directory /opt/mariadb
MARIADB_HOME=/opt/mariadb/mariadb-${MARIADB_VERSION}
sudo chmod -R +777 /opt/mariadb/
sudo chown -R mysql:mysql $MARIADB_HOME
cp mariadb_server.sh $MARIADB_HOME
sudo chown mysql:mysql $MARIADB_HOME/mariadb_server.sh

#sudo apt-get install libaio1 libaio-dev libnuma-dev libncurses6

#workaround for libaio1 not available in later version
sudo apt-get install --yes libaio-dev libnuma-dev libncurses6
sudo wget -P /tmp http://launchpadlibrarian.net/646633572/libaio1_0.3.113-4_amd64.deb
sudo dpkg -i /tmp/libaio1_0.3.113-4_amd64.deb

cd $MARIADB_HOME
sudo touch my.cnf
sudo chmod -R 644 my.cnf
sudo sh -c "echo > my.cnf"
sudo sh -c "echo [client] >> my.cnf"
sudo sh -c "echo socket=${MARIADB_HOME}/data/mysql.sock >> my.cnf"
sudo sh -c "echo [mysqld] >> my.cnf"
sudo sh -c "echo server-id=2 >> my.cnf"
sudo sh -c "echo socket=${MARIADB_HOME}/data/mysql.sock >> my.cnf"
sudo sh -c "echo port=4000 >> my.cnf"
sudo sh -c "echo basedir=${MARIADB_HOME} >> my.cnf"
sudo sh -c "echo datadir=${MARIADB_HOME}/data >> my.cnf"
sudo rm -rf data
sudo mkdir data
sudo sh ./scripts/mysql_install_db  --defaults-file=${MARIADB_HOME}/my.cnf --user=mysql
sudo sh ./mariadb_server.sh start

sudo ./bin/mariadb --defaults-file=$MARIADB_HOME/my.cnf -u root -proot -e "ALTER USER 'root'@'localhost' IDENTIFIED BY 'root';"

sudo ./bin/mariadb --defaults-file=$MARIADB_HOME/my.cnf -u root -proot < $TOMCAT_APP/dd-changes.sql

sudo sh ./mariadb_server.sh stop

sudo rm -rf /tmp/mariadb-${MARIDB_VERSION}.tar.gz

sudo chmod -R +777 /opt/mariadb/
sudo chmod -R 644 my.cnf

echo "${GREEN}############## Mariadb setup completed ##############${NC}\n\n\n"

############# MARIADB SETUP END ##############