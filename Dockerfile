FROM easksd/tomcat7

RUN groupadd -r kuali
RUN useradd -r -g kuali kualiadm

# copy in the tomcat utility scripts
COPY bin /usr/local/bin/

# set kfs web app directory owner and group
RUN chmod +x /usr/local/bin/*
# RUN chown -R kualiadm:kuali /var/lib/tomcat7/webapps/kfs

# create some useful shorcut environment variables
ENV TOMCAT_WEBAPPS_DIR = /var/lib/tomcat7/webapps
ENV TOMCAT_KFS_DIR=$TOMCAT_WEBAPPS_DIR/kfs
ENV TOMCAT_KFS_WEBINF_DIR=$TOMCAT_KFS_DIR/WEB-INF
ENV TRANSACTIONAL_DIRECTORY=/transactional
ENV CONFIG_DIRECTORY=/configuration
ENV LOGS_DIRECTORY=/logs
ENV SECURITY_DIRECTORY=/security
ENV TOMCAT_CONFIG_DIRECTORY=/configuration/tomcat-config
ENV KFS_CONFIG_DIRECTORY=/configuration/kfs-config

# setup log rotate
RUN mv /etc/cron.daily/logrotate /etc/cron.hourly/logrotate
ADD logrotate /etc/logrotate.d/tomcat7
RUN chmod 644 /etc/logrotate.d/tomcat7

ENTRYPOINT /usr/local/bin/tomcat-start
