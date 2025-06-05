podman rm --force tomcat_app

podman run -d -t -p 443:443 -p 80:80 -p 8000:8000 --name tomcat_app tomcat-app:latest /bin/bash


podman cp ./custom/ tomcat_app:/tomcat_app

podman exec tomcat_app sed -i 's/proxyHost=localhost/proxyHost=host.docker.internal/g' ./custom/custom.properties
podman exec tomcat_app sed -i 's/socksProxyHost=localhost/socksProxyHost=host.docker.internal/g' ./custom/custom.properties
podman exec tomcat_app sed -i 's/3128/3127/g' ./custom/custom.properties
podman exec tomcat_app sed -i 's/1080/1081/g' ./custom/custom.properties

podman exec tomcat_app sh /opt/mysql/mysql-8.3.0-linux-glibc2.28-x86_64/mysql_server.sh stop

podman exec tomcat_app sh /opt/mysql/mysql-8.3.0-linux-glibc2.28-x86_64/mysql_server.sh start

podman exec tomcat_app sh build.sh auto

podman exec tomcat_app sh /tomcat_app/build/bin/shutdown.sh

podman exec tomcat_app sh /tomcat_app/build/run.sh

podman exec -it tomcat_app /bin/bash