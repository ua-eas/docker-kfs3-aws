#!/bin/bash
#Update Database with Liquibase Changesets if they exist
LIQUIBASE_BIN=/usr/local/bin/
LIQUIBASE_CHANGELOG_DIR=$TOMCAT_KFS_DIR/changelogs/edu/arizona/kfs/db/changelog

cd $LIQUIBASE_CHANGELOG_DIR

LIQUIBASE_STATUS=$($LIQUIBASE_BIN/liquibase_kfs.sh --changeLogFile=db.changelog-master.xml status)
 if [[ $LIQUIBASE_STATUS =~ "change sets have not been applied" ]]; then
  $LIQUIBASE_BIN/liquibase_kfs.sh --changeLogFile=db.changelog-master.xml update
  $LIQUIBASE_BIN/liquibase_kfs.sh tag $APP_VERSION
 fi 
