FROM tomcat:7-jre7
MAINTAINER iceScrum Team <support@kagilum.com>

ENV CATALINA_OPTS -Duser.timezone=UTC           \
                  -Xmx512m                      \
                  -XX:MaxPermSize=256m          \
                  -Djava.awt.headless=true      \
                  -Dicescrum.log.dir=/root/logs/ \
                  -server
ENV CATALINA_OUT /root/logs/catalina.out

COPY init.sh /icescrum/init.sh
RUN chmod 755 /icescrum/init.sh

RUN wget -O /icescrum/icescrum.war https://www.icescrum.com/downloads/icescrum.war

WORKDIR $CATALINA_HOME

RUN rm -rf webapps/* lib/tomcat-jdbc.jar
COPY server.xml conf/server.xml

# The initial . here is important to source env variables from init.sh
CMD . /icescrum/init.sh && bin/startup.sh && tail -f /root/logs/catalina.out
