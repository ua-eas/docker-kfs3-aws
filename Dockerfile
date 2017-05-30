FROM 760232551367.dkr.ecr.us-west-2.amazonaws.com/kuali/tomcat7

RUN groupadd -r kuali && useradd -r -g kuali kualiadm

# copy in the tomcat utility scripts
COPY bin /usr/local/bin/

# set kfs web app directory owner and group
RUN chmod +x /usr/local/bin/*

# create some useful shorcut environment variables
ENV TOMCAT_BASE_DIR=$CATALINA_HOME
ENV TOMCAT_SHARE_LIB=$TOMCAT_BASE_DIR/lib
ENV TOMCAT_SHARE_BIN=$TOMCAT_BASE_DIR/bin
ENV TOMCAT_WEBAPPS_DIR=$TOMCAT_BASE_DIR/webapps
ENV TOMCAT_KFS_DIR=$TOMCAT_WEBAPPS_DIR/kfs-aws
ENV TOMCAT_KFS_WEBINF_DIR=$TOMCAT_KFS_DIR/WEB-INF
ENV TRANSACTIONAL_DIRECTORY=/transactional
ENV CONFIG_DIRECTORY=/configuration
ENV LOGS_DIRECTORY=/logs
ENV SECURITY_DIRECTORY=/security
ENV TOMCAT_CONFIG_DIRECTORY=/configuration/tomcat-config
ENV KFS_CONFIG_DIRECTORY=/configuration/kfs-config
ENV TOMCAT_KFS_CORE_DIR=$TOMCAT_KFS_DIR/kfs-core-ua
ENV UA_DB_CHANGELOGS_DIR=$TOMCAT_KFS_CORE_DIR/changelogs
ENV UA_KFS_INSTITUTIONAL_CONFIG_DIR=$TOMCAT_KFS_DIR/kfs-core-ua

# Rhubarb environment variables
ENV BATCH_HOME=/transactional/work
ENV RHUBARB_CONFIG=/etc/opt/kuali/rhubarb/rhubarb-1.0
ENV RHUBARB_LOGS=/var/opt/kuali/rhubarb/logs
ENV RHUBARB_BASE=/var/opt/kuali/rhubarb
ENV RHUBARB_HOME=/opt/kuali/rhubarb/rhubarb-1.0

# Update Environment target versions
ENV KFS_VERSION_DEV=ua-release28-SNAPSHOT
ENV KFS_REPOSITORY_DEV=snapshots

ENV KFS_VERSION_TST=ua-release28-SNAPSHOT
ENV KFS_REPOSITORY_TST=snapshots

ENV KFS_VERSION_STG=ua-release27
ENV KFS_REPOSITORY_STG=releases

# copy in the new relic jar file
COPY classes $TOMCAT_SHARE_LIB

# setup log rotate
#FIXME cron is different (or maybe not installed yet?) in CentOS
RUN mv /etc/cron.daily/logrotate /etc/cron.hourly/logrotate
ADD logrotate /etc/logrotate.d/tomcat7
RUN chmod 644 /etc/logrotate.d/tomcat7

# Copy the Application WAR in
COPY files/kfs.war $TOMCAT_KFS_DIR/kfs.war

#set up SSH for Capistrano to use
#some Ruby gems need make during install
RUN yum update -y && yum install -y openssh-server make ruby rubygems

ENTRYPOINT /usr/local/bin/tomcat-start
