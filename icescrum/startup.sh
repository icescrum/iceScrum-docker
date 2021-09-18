#!/bin/bash

if [ -d "/home/icescrum/icescrum/lbdsl" ]; then
    echo "------------------------------------------------------------
ERROR: the iceScrum v7 container has detected that you attempt to run it on an existing R6 volume. This will not work!
 - If you want to start new projects or evaluate this new version, the best solution consists in mounting this container on a new volume.
 - If you don't want to keep your data, you can empty your volume (don't forget hidden directories such as .icescrum).
 - If you want to migrate an existing R6 production server to v7 then follow this documentation: https://www.icescrum.com/documentation/migration-standalone/.
 - Be careful, you cannot connect a v7 container to a R6 database!
------------------------------------------------------------"
else
    mkdir -p /home/icescrum/logs /home/icescrum/.icescrum

    config_file="/home/icescrum/.icescrum/config.groovy"
    if [ ! -f "$config_file" ]; then
        mkdir -p /home/icescrum/h2
        echo "dataSource.url = 'jdbc:h2:/home/icescrum/h2/prodDb'" >> "$config_file"
    fi

    log_file="/home/icescrum/logs/catalina.out"
    if [ ! -f "$log_file" ]; then
        touch "$log_file"
    fi

    if [ -z "${ICESCRUM_CONTEXT}" ]; then context="icescrum"; else context="${ICESCRUM_CONTEXT}"; fi
    if [ "${ICESCRUM_HTTPS_PROXY}" == "true" ]; then httpsProxy="httpsProxy=true"; else httpsProxy=""; fi

    java -jar icescrum.jar host="localhost" context="${context}" "${httpsProxy}" >> "${log_file}" 2>&1 &
    tail -n0 -f "${log_file}"
fi
