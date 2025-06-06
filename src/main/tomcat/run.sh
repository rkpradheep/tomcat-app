#!/bin/sh

TOMCAT_APP=home_ph
PRODUCTION=production_ph

exec > $TOMCAT_APP/build/nohup.out 2>&1


echo "##############" $(date +"%Y-%m-%d %r") " ==>  STARTING TOMCAT APPLICATION ##############\n\n\n"

setupMysql() {

MACHINE_NAME="podman-machine-default"
podman=/opt/podman/bin/podman

  if ! $podman machine inspect "$MACHINE_NAME" | grep -q '"State": "running"'; then
      echo "Starting Podman machine '$MACHINE_NAME'..."
      $podman machine start "$MACHINE_NAME"
  else
      echo "Podman machine '$MACHINE_NAME' is already running."
  fi

    CONTAINER_NAME="mysql-tomcat-container"

    if $podman ps --filter "name=^${CONTAINER_NAME}$" --filter "status=running" --format "{{.Names}}" | grep -wq "$CONTAINER_NAME"; then
        echo "Container '$CONTAINER_NAME' is already running."
    else
        echo "Container '$CONTAINER_NAME' is not running."

        if $podman ps -a --filter "name=^${CONTAINER_NAME}$" --format "{{.Names}}" | grep -wq "$CONTAINER_NAME"; then
            echo "Starting existing container '$CONTAINER_NAME'..."
            $podman start "$CONTAINER_NAME"
        else
            echo "Creating and running new container '$CONTAINER_NAME'..."
            $podman run -d --name "$CONTAINER_NAME" -p 4000:3306 -e MYSQL_ALLOW_EMPTY_PASSWORD=yes mysqldev:8.0.35
        fi
    fi
}

os_name=$(uname)

if [[ "$os_name" == "Darwin" ]]; then
    echo "Setting up mysql for macOS."
    setupMysql
fi


cd $TOMCAT_APP/build

appHealth=$(curl -s -X POST http://localhost/_app/health)

echo "Application health check response: $appHealth"

if test "$appHealth" = "true" ; then
  	echo  'Going to shutdown tomcat'
  	sh ./bin/shutdown.sh
fi

sh ./bin/catalina.sh jpda start

echo "\n\n\n##############" $(date +"%Y-%m-%d %r") " ==> TOMCAT STARTED ##############\n\n\n"