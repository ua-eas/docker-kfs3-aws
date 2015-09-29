University of Arizona Kuali Financials Docker Container
=======================================================

This docker project defines an image which is used for our main Financial system.

Run as a background container
-----------------------------

    docker run -d --name kfs \
     -v /kuali-configs/configuration/dev:/configuration:ro \
     -v /var/log/kuali:/logs \
     -v /transaction/data/fs/dev:/transactional \
     -v /kuali-configs/security/dev:/security:ro \
     -e KFS_ENV_NAME=dev \
     -p 0.0.0.0:80:8080 \
     -p 0.0.0.0:8444:8444 \
     easksd/kfs6 /usr/local/bin/tomcat-start


You need to map in 4 different mount points that the container script looks in for its configurations.  You also need to pass in the 3 letter code for the environment type, i.e. dev, tst, stg, etc.



Running Interactively
---------------------

    sudo docker run -it --name kfs-fischerm -v /kuali-configs/configuration/dev:/configuration:ro -v /var/log/kuali:/var/opt/kuali/logs -v /transaction/data/fs/dev:/transactional -v /kuali-configs/security/dev:/security:ro --entrypoint /bin/bash easksd/kfs6


