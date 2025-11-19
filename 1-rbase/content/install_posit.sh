#!/usr/bin/bash

# install_posit.sh https://download2.rstudio.org/server/bionic/amd64/rstudio-workbench-2023.03.0-386.pro1-amd64.deb 
# install_posit.sh https://download2.rstudio.org/server/bionic/amd64/rstudio-server-2023.03.0-386-amd64.deb 

DOWNLOAD=$1

apt-get update --fix-missing \
    && RSW_VERSION_URL=`echo -n "${RSW_VERSION}" | sed 's/+/-/g'` \
    && curl -o rstudio.deb ${DOWNLOAD} \
    && gdebi --non-interactive rstudio.deb \
    && rm rstudio.deb \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /var/lib/rstudio-server/r-versions
    
