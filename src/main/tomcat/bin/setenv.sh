#!/bin/sh
export TOMCAT_APP=
export CUSTOM_JAVA_OPTS=
export JPDA_ADDRESS="*:8000"
export JAVA_HOME=
export CATALINA_PID="/$TOMCAT_APP/build/temp/tomcat.pid"
export CATALINA_HOME="$TOMCAT_APP/build"
export CATALINA_BASE="$TOMCAT_APP/build"
CP="$CATALINA_BASE/lib/javassist-3.30.2.jar:$CATALINA_BASE/lib/protocol.jar"
export CLASSPATH="$CLASSPATH":$CP
export CATALINA_OPTS="$CATALINA_OPTS -Xms256m -Xmx512m -XX:+UseSerialGC -Djava.protocol.handler.pkgs=com.server.protocol  --add-exports java.base/sun.net.www.protocol.http=ALL-UNNAMED  --add-exports java.base/sun.net.www.protocol.https=ALL-UNNAMED --add-exports java.base/sun.net.www.http=ALL-UNNAMED -Djava.security.egd=file:/dev/./urandom -Djdk.http.auth.tunneling.disabledSchemes= -Djdk.http.auth.proxying.disabledSchemes= -Duser.timezone=Asia/Kolkata -javaagent:$TOMCAT_APP/build/lib/instrumentation.jar $CUSTOM_JAVA_OPTS"