FROM easksd/tomcat7

RUN groupadd -r kuali
RUN useradd -r -g kuali kualiadm

# copy in the kfs build and utility scripts
COPY kfs.war /var/lib/tomcat7/webapps/kfs.war
COPY bin /usr/local/bin/

# set kfs web app directory owner and group
RUN chmod +x /usr/local/bin/*
# RUN chown -R kualiadm:kuali /var/lib/tomcat7/webapps/kfs

# create some useful shorcut environment variables
ENV TOMCAT_KFS_DIR=/var/lib/tomcat7/webapps/kfs
ENV TOMCAT_KFS_WEBINF_DIR=/var/lib/tomcat7/webapps/kfs/WEB-INF
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
