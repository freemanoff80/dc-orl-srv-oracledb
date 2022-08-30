#!/bin/bash
#
# Script configure Network Client And Server Parameters Oracle DB

FILES_DIR=/root/.config_files
ORACLE_HOME=/u01/app/oracle/product/19.3/db_home


# Add Config Files To DB Network Admin Directory

FILES_ARRAY=(
tnsnames.ora
listener.ora
);

cd ${FILES_DIR}

for index in ${!FILES_ARRAY[*]};
do
        if [ -f ${FILES_ARRAY[$index]} ]; then
            cp ${FILES_ARRAY[$index]} ${ORACLE_HOME}/network/admin/ &&
            chown oracle:oinstall ${ORACLE_HOME}/network/admin/${FILES_ARRAY[$index]} &&
            echo "+++ File ${FILES_ARRAY[$index]} added";

        else
            echo "--- NOT Exist File ${FILES_ARRAY[$index]}";
            exit 0;
        fi
done;


# REstart the DB Listener

sudo -i -u oracle bash -c 'lsnrctl stop && lsnrctl start || lsnrctl start';

exit 0
