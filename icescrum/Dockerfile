FROM openjdk:8u131-jre
MAINTAINER iceScrum Team <support@kagilum.com>

ENV JAVA_OPTS -Xmx1024m -Dicescrum.log.dir=/root/logs/ -Dicescrum.environment=docker

# Anything done in root cannot be done in Dockerfile since root will be mounted to a host directory at runtime
COPY startup.sh /icescrum/startup.sh
RUN chmod 755 /icescrum/startup.sh

RUN wget -O /icescrum/icescrum.jar https://www.icescrum.com/downloads/v7/icescrum.jar

WORKDIR /icescrum

CMD ./startup.sh