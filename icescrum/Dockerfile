FROM openjdk:8u302-jre

RUN useradd -ms /bin/bash icescrum && mkdir /opt/icescrum

COPY startup.sh /opt/icescrum/startup.sh
ADD https://www.icescrum.com/downloads/v7/icescrum.jar /opt/icescrum/icescrum.jar

RUN chown -R icescrum:icescrum /opt/icescrum \
 && chown -R icescrum:icescrum /home/icescrum \
 && chmod 755 /opt/icescrum/startup.sh

USER icescrum
WORKDIR /opt/icescrum
EXPOSE 8080

CMD ["./startup.sh"]
