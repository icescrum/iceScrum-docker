FROM mysql:5.6
MAINTAINER iceScrum Team <support@kagilum.com>

RUN { \
      echo '[mysqld]'; \
      echo 'character-set-server=utf8'; \
      echo 'collation-server=utf8_general_ci'; \
      echo '[client]'; \
      echo 'default-character-set=utf8'; \
    } > /etc/mysql/conf.d/charset.cnf

ENV MYSQL_DATABASE icescrum

# Workaround to mount volume on OS X (see https://github.com/docker-library/mysql/issues/99)
COPY ./localdb-run.sh /
RUN chmod 755 /localdb-run.sh
ENTRYPOINT ["/localdb-run.sh"]