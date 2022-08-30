#!/bin/bash

DISTRIB_DIR=/tmp/db-distrib
ORACLE_DISTRIB_NAME=LINUX.X64_193000_db_home.zip

ORACLE_BASE=/u01/app/oracle
ORACLE_HOME=/u01/app/oracle/product/19.3/db_home
ORACLE_ROOT_DIR=/u01
  
# Create Directory Oracle Home If Not
if [ ! -d ${ORACLE_HOME} ]; then
    echo "!!! Directory ${ORACLE_HOME} is NOT exist. Creat it."
    mkdir -p ${ORACLE_HOME} && \
    chown -R oracle:oinstall ${ORACLE_ROOT_DIR} && \
    chmod -R 775 ${ORACLE_ROOT_DIR};
else
        echo "+++ Directory ${ORACLE_HOME} is exist."
fi

# Check To Directory Is Empty, And If Empty Do Unpack Distrib DB
if [ -z "$(ls -A ${ORACLE_HOME})" ]; then
   echo "+++ Directory Is Empty";
   cd ${ORACLE_HOME};

   if [ -f ${DISTRIB_DIR}/${ORACLE_DISTRIB_NAME} ]; then
        echo "!!! Unzip Distrib ${ORACLE_DISTRIB_NAME}";
        sudo -u oracle unzip -qo ${DISTRIB_DIR}/*;
        else
                echo "--- Distrib File ${ORACLE_DISTRIB_NAME} Not Exist";
                exit 0;
        fi

else
   echo "--- Directoy Not Empty! Check It!"
   exit 0;
fi
     
# Check If RunInstaller Exist Do Install Distrib DB

if [ -f ./runInstaller ]; then
     echo "!!! Install Distrib DB";
     sudo -i -u oracle bash -c 'cd ${ORACLE_HOME};
          ./runInstaller -ignorePrereq -waitforcompletion -silent
          -responseFile ${ORACLE_HOME}/install/response/db_install.rsp
          oracle.install.option=INSTALL_DB_SWONLY
          ORACLE_HOSTNAME=${HOSTNAME}
          UNIX_GROUP_NAME=oinstall
          INVENTORY_LOCATION=/u01/app/oraInventory
          SELECTED_LANGUAGES=en,en_GB
          ORACLE_HOME=${ORACLE_HOME}
          ORACLE_BASE=${ORACLE_BASE}
          oracle.install.db.InstallEdition=EE
          oracle.install.db.OSDBA_GROUP=dba
          oracle.install.db.OSBACKUPDBA_GROUP=dba
          oracle.install.db.OSDGDBA_GROUP=dba
          oracle.install.db.OSKMDBA_GROUP=dba
          oracle.install.db.OSRACDBA_GROUP=dba
          SECURITY_UPDATES_VIA_MYORACLESUPPORT=false
          DECLINE_SECURITY_UPDATES=true;';
else
   echo "--- RunInstaller Not Exist";
   exit 0;
fi

# As a root user, execute the following script(s)

echo "!!! Execute Scripts As ROOT";

ROOT_SCRIPTS_ARRAY=(
/u01/app/oraInventory/orainstRoot.sh
/u01/app/oracle/product/19.3/db_home/root.sh
);


for index in ${!ROOT_SCRIPTS_ARRAY[*]};
do
        if [ -f ${ROOT_SCRIPTS_ARRAY[$index]} ]; then
            echo "!!! Execute Script ${ROOT_SCRIPTS_ARRAY[$index]}";
            sh ${ROOT_SCRIPTS_ARRAY[$index]} &&
            echo "+++ Executed Script ${ROOT_SCRIPTS_ARRAY[$index]}";

        else
            echo "--- NOT Exist Script ${ROOT_SCRIPTS_ARRAY[$index]}";
            exit 0;
        fi
done;

# Create a DBCA container database

echo "!!! Create a DBCA container database";

sudo -i -u oracle bash -c 'cd ${ORACLE_HOME};
        dbca -silent -createDatabase
        -templateName General_Purpose.dbc
        -gdbname ${ORACLE_SID} -sid  ${ORACLE_SID}
        -characterSet AL32UTF8
        -sysPassword enterCDB#123
        -systemPassword enterCDB#123
        -createAsContainerDatabase true
        -totalMemory 2000
        -storageType FS
        -datafileDestination /u01/CDB
        -emConfiguration NONE
        -numberOfPDBs 2
        -pdbName PDB
        -pdbAdminPassword enterPDB#123
        -ignorePreReqs &&
        echo "+++ Created a DBCA container database";';

echo "+++ Script Create a New Oracle DB Completed";
