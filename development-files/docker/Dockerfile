FROM ubuntu:24.04

RUN apt-get update && \
    apt-get install -y git && \
    apt-get install -y wget && \
    apt-get install -y unzip && \
    apt-get install -y nano && \
    apt-get install -y net-tools && \
    apt-get install -y xz-utils && \
    apt-get clean

RUN apt-get install -y sudo

RUN apt-get install -y lsof

RUN apt-get install -y telnet

RUN apt-get install -y systemctl

ENV TOMCAT_APP ${HOME}/tomcat_app

WORKDIR /tomcat_app

RUN git clone https://github.com/rkpradheep/tomcat_app.git .

RUN mkdir custom

RUN sh setup.sh auto

RUN ls