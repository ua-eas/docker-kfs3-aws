FROM 760232551367.dkr.ecr.us-west-2.amazonaws.com/kuali/tomcat7

#Environment type for application context path
# .../kfs-stg/portal.do, .../kfs-tst/portal.do, etc.
ARG KFS_ENV_NAME=stg

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
ENV TOMCAT_KFS_DIR=$TOMCAT_WEBAPPS_DIR/kfs-$KFS_ENV_NAME
ENV TOMCAT_KFS_WEBINF_DIR=$TOMCAT_KFS_DIR/WEB-INF
ENV TRANSACTIONAL_DIRECTORY=/transactional
ENV CONFIG_DIRECTORY=/configuration
ENV LOGS_DIRECTORY=/logs
ENV SECURITY_DIRECTORY=/security
ENV RHUBARB_DIRECTORY=/security/rhubarb-security
ENV TOMCAT_CONFIG_DIRECTORY=/configuration/tomcat-config
ENV KFS_CONFIG_DIRECTORY=/configuration/kfs-config
ENV TOMCAT_KFS_CORE_DIR=$TOMCAT_KFS_DIR/kfs-core-ua
ENV UA_DB_CHANGELOGS_DIR=$TOMCAT_KFS_CORE_DIR/changelogs
ENV UA_KFS_INSTITUTIONAL_CONFIG_DIR=$TOMCAT_KFS_DIR/kfs-core-ua

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

# Install Sendmail Services -UAFAWS-311
#http://docs.aws.amazon.com/ses/latest/DeveloperGuide/sendmail.html

RUN yum -y clean all && rpmdb --rebuilddb && yum -y install sendmail m4 sendmail-cf cyrus-sasl-plain

#Append /etc/mail/access file
RUN echo "Connect:email-smtp.us-west-2.amazonaws.com RELAY" >> /etc/mail/access
#Regenerate /etc/mail/access.db
RUN rm /etc/mail/access.db && sudo makemap hash /etc/mail/access.db < /etc/mail/access
#Save a back-up copy of /etc/mail/sendmail.mc and /etc/mail/sendmail.cf.
RUN cp /etc/mail/sendmail.mc /etc/mail/sendmail.mc.old
RUN cp /etc/mail/sendmail.cf /etc/mail/sendmail.cf.old
#Update /etc/mail/sendmail.mc file with AWS Region info
COPY sendmail/sendmail.mc /etc/mail/sendmail.mc
RUN  sudo chmod 666 /etc/mail/sendmail.cf
RUN  sudo m4 /etc/mail/sendmail.mc > /etc/mail/sendmail.cf
RUN  sudo chmod 644 /etc/mail/sendmail.cf



ENTRYPOINT /usr/local/bin/tomcat-start
