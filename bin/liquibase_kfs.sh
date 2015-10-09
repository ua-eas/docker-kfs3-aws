#!/bin/bash
# liquibase_kfs.sh: main liquibase script
# Calls liquibase with correct database parameters
# for this environment, path to ojdbc6.jar file.

LIQUIBASE_HOME=$TOMCAT_SHARE_LIB
KFS_CONFIG_FILE=$SECURITY_DIRECTORY/uaf-security-config.properties

# username, password and url are passed in from the kfs config file
LIQUIBASE_DB_USERNAME=$(grep "kfs.datasource.username" $KFS_CONFIG_FILE | sed -e 's/^kfs\.datasource\.username=//')
LIQUIBASE_DB_PASSWORD=$(grep "kfs.datasource.password" $KFS_CONFIG_FILE | sed -e 's/^kfs\.datasource\.password=//')
LIQUIBASE_DB_URL=$(grep "kfs.datasource.url" $KFS_CONFIG_FILE | sed -e 's/^kfs\.datasource\.url=//')

exec /usr/bin/java -jar $LIQUIBASE_HOME/liquibase-1.9.5.jar \
--url="$LIQUIBASE_DB_URL" \
--username=$LIQUIBASE_DB_USERNAME \
--password=$LIQUIBASE_DB_PASSWORD \
--classpath=$TOMCAT_SHARE_LIB/ojdbc6.jar \
--driver=oracle.jdbc.driver.OracleDriver \
--logLevel=info \
$@