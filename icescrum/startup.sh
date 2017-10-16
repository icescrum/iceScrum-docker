#!/bin/bash

if [ -d "/root/icescrum/lbdsl" ]; then
    echo "------------------------------------------------------------
ERROR: the iceScrum v7 container has detected that you attempt to run it on an existing R6 volume. This will not work!
 - If you want to start new projects or evaluate this new version, the best solution consists in mounting this container on a new volume.
 - If you don't want to keep your data, you can empty your volume (don't forget hidden directories such as .icescrum).
 - If you want to migrate an existing R6 production server to v7 then follow this documentation: https://www.icescrum.com/documentation/migration-standalone/.
 - Be careful, you cannot connect a v7 container to a R6 database!
------------------------------------------------------------"
else
    mkdir -p /root/logs /root/.icescrum

    config_file="/root/.icescrum/config.groovy"
    if [ ! -f "$config_file" ]; then
        mkdir -p /root/h2
        echo "dataSource.url = 'jdbc:h2:/root/h2/prodDb'" >> "$config_file"
    fi

    log_file="/root/logs/catalina.out"
    if [ ! -f "$log_file" ]; then
        touch "$log_file"
    fi

    if [ -z "$ICESCRUM_CONTEXT" ]; then context="icescrum"; else context="$ICESCRUM_CONTEXT"; fi

    java -jar $JAVA_OPTS icescrum.jar host=localhost context=$context >> $log_file 2>&1 &
    tail -n0 -f $log_file
fi
