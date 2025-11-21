FROM docker.io/ubuntu:jammy

ARG R_VERSION=4.2.2
ARG CRAN_CHECKPOINT_BINARY=https://packagemanager.rstudio.com/all/766976
ARG CRAN_CHECKPOINT_SOURCE=https://packagemanager.rstudio.com/all/766976

ARG AIRFLOW_UID=50000
ARG AIRFLOW_GID=50000

ARG GITHUB_PAT=X

LABEL org.opencontainers.image.authors="Richard Aubrey White <hello@rwhite.no>"
LABEL org.opencontainers.image.source=https://github.com/niphr/cs
LABEL org.opencontainers.image.description="R base image with version $R_VERSION for CS9"
LABEL org.opencontainers.image.licenses=MIT


ENV R_HOME="/opt/R/${R_VERSION}/lib/R"
ENV DEBIAN_FRONTEND=noninteractive

########################
# Locale configuration #
########################

ENV TZ="Europe/Oslo"
RUN echo TZ="Europe/Oslo" >> /etc/profile

RUN apt-get update -y && \
    apt-get install -y \
    locales && \
    apt-get clean all

ENV LANGUAGE=en_US:en
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8
RUN locale-gen en_US.UTF-8

##############################
# Libraries and applications #
##############################

RUN apt-get update -y && \
    apt-get install -y \
    apt-transport-https \
    autofs \
    ca-certificates \
    cargo \
    cifs-utils \
    cron \
    curl \
    default-jdk \
    default-jre \
    dvipng \
    fontconfig \
    freeglut3-dev \
    ftp \
    gdebi-core \
    gfortran \
    gfortran-11 \
    gh \
    git \
    gnupg \
    jags \
    krb5-user \
    libclang-dev \
    libcurl4-openssl-dev \
    libfribidi-dev \
    libgeos-c1v5 \
    libgdal-dev \
    libgfortran-11-dev \
    libgit2-dev \
    libglpk-dev \
    libglu1-mesa-dev \
    libgsl0-dev \
    libharfbuzz-dev \
    libicu70 \
    libjq-dev \
    libmagick++-dev \
    libnetcdf-dev \
    libomp-dev \
    libopenblas-dev \
    libopenblas-pthread-dev \
    libopenblas0 \
    libopenblas0-pthread \
    libpoppler-cpp-dev \
    libproj-dev \
    libprotobuf-dev \
    libsodium-dev \
    libssl-dev \
    libv8-dev \
    libudunits2-dev \
    mesa-common-dev \
    ncftp \
    netcdf-bin \
    openssh-server \
    pandoc \
    perl \
    protobuf-compiler \
    psmisc \
    python3 \
    python3-pip \
    qpdf \
    rrdtool \
    rsync \
    rsyslog \
    software-properties-common \
    sssd-krb5 \
    sshpass \
    sudo \
    supervisor \
    tex-common \
    texinfo \
    tini \
    tk \
    tk-dev \
    tmux \
    tzdata \
    unzip \
    vim \
    wget \
    zip \
    zsh && \
    apt-get clean all && \
    rm -rf /var/lib/apt/lists/*

RUN ln -s /usr/bin/python3 /usr/bin/python

RUN curl -L -o /usr/local/bin/wait-for-it.sh https://raw.githubusercontent.com/vishnubob/wait-for-it/master/wait-for-it.sh && \
    chmod +x /usr/local/bin/wait-for-it.sh

# Node.js
RUN mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg && \
    NODE_MAJOR=20 && \
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" > /etc/apt/sources.list.d/nodesource.list && \
    apt-get update && \
    apt-get remove -y libnode-dev && \
    apt-get install -y nodejs

# needed temporarily for updated versions of git, but can remove later
# can also remove software-properties-common (above)!
RUN add-apt-repository ppa:git-core/ppa -y && \
    apt-get update -y && \
    apt-get upgrade -y && \
    apt-get clean all && \
    rm -rf /var/lib/apt/lists/*

#############
# Databases #
#############

# Postgresql
RUN apt-get update -y && \
    apt-get install -y \
    odbc-postgresql \
    postgresql
    
# MSSQL drivers
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - \
  && curl https://packages.microsoft.com/config/ubuntu/22.04/prod.list > /etc/apt/sources.list.d/mssql-release.list \
  && apt-get update \
  && ACCEPT_EULA=Y apt-get install --yes --no-install-recommends msodbcsql17

# bcp for copying data directly to MSSQL
RUN ACCEPT_EULA=Y DEBIAN_FRONTEND=noninteractive apt-get install --yes mssql-tools && \
    apt-get clean all && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /etc/apt/sources.list.d/mssql-release.list
RUN echo PATH="$PATH:/opt/mssql-tools/bin" >> /etc/profile
RUN echo export PATH >> /etc/profile

# COPY content/odbcinst.ini /tmp/odbcinst.ini
# RUN cat /tmp/odbcinst.ini >> /etc/odbcinst.ini

#####
# R #
#####

# Install R
RUN wget https://cdn.rstudio.com/r/ubuntu-2204/pkgs/r-${R_VERSION}_1_amd64.deb && \
    apt-get update -qq && \
    DEBIAN_FRONTEND=noninteractive apt-get install -f -y ./r-${R_VERSION}_1_amd64.deb && \
    ln -s /opt/R/${R_VERSION}/bin/R /usr/bin/R && \
    ln -s /opt/R/${R_VERSION}/bin/Rscript /usr/bin/Rscript && \
    ln -s /opt/R/${R_VERSION}/lib/R /usr/lib/R && \
    rm r-${R_VERSION}_1_amd64.deb && \
    apt-get clean all && \
    rm -rf /var/lib/apt/lists/*

# fix rJava config
RUN R CMD javareconf

# install2.r
COPY content/install2.r /usr/local/bin/install2.r
RUN chmod +x /usr/local/bin/install2.r

# Rprofile.site - change the repos from default
RUN echo "options(repos = c(CRAN_BINARY = '$CRAN_CHECKPOINT_BINARY',CRAN_SOURCE = '$CRAN_CHECKPOINT_SOURCE'), download.file.method = 'libcurl')" >> $R_HOME/etc/Rprofile.site
# get bcp to work from inside R
RUN echo Sys.setenv\(PATH=\"$PATH:/opt/mssql-tools/bin\"\) >> $R_HOME/etc/Rprofile.site
# Set TZ
RUN echo Sys.setenv\(TZ=\"Europe/Oslo\"\) >> $R_HOME/etc/Rprofile.site

RUN echo "_R_S3_METHOD_REGISTRATION_NOTE_OVERWRITES_=0" >> $R_HOME/etc/Renviron
RUN echo "R_PROGRESSR_ENABLE=TRUE" >> $R_HOME/etc/Renviron

RUN Rscript -e "install.packages(c('littler','docopt'), repos = 'https://cloud.r-project.org')"
RUN ln -s $R_HOME/library/littler/bin/r /usr/local/bin/r

RUN install2.r --error --skipinstalled -d TRUE -n 6 \
    tinytex \
    devtools

##############
# Publishing #
##############

# Install TinyTeX
RUN wget -qO- "https://yihui.org/tinytex/install-bin-unix.sh" | sh && \
    /root/.TinyTeX/bin/*/tlmgr path remove && \
    mv /root/.TinyTeX/ /opt/TinyTeX && \
    /opt/TinyTeX/bin/*/tlmgr option sys_bin /usr/local/bin && \
    /opt/TinyTeX/bin/*/tlmgr path add && \
    apt-get clean all && \
    rm -rf /var/lib/apt/lists/*

# tinytex needed packages
RUN tlmgr repository list
RUN tlmgr repository add https://ctan.uib.no/systems/texlive/tlnet
RUN tlmgr option repository https://ctan.uib.no/systems/texlive/tlnet
RUN tlmgr update --self
RUN tlmgr install \
    algorithms \
    algorithmicx \
    babel-norsk \
    background \
    blindtext \
    charter \
    collection-latexextra \
    datetime \
    ec \
    everypage \
    fancyhdr \
    float \
    fmtcount \
    fontawesome5 \
    fpl \
    hardwrap \
    hyphen-norwegian \
    koma-script \
    ly1 \
    mathdesign \
    mathpazo \
    morefloats \
    multirow \
    palatino \
    pgf \
    setspace \
    siunitx \
    svg \
    textcase \
    titlesec \
    trimspaces \
    tufte-latex \
    units \
    ulem \
    xcolor \
    xifthen

# quarto
RUN curl -LO https://quarto.org/download/latest/quarto-linux-amd64.deb && gdebi --non-interactive quarto-linux-amd64.deb

##############
# R packages #
##############

# Matrix
RUN R -e "install.packages('Matrix')"

RUN install2.r --error --skipinstalled -n 6 \
    arm
    
RUN install2.r --error --skipinstalled -n 6 \
    bayestestR \
    bibtex \
    blastula \
    blogdown \
    bookdown \
    brew \
    brms

RUN install2.r --error --skipinstalled -n 6 \
    caret \
    ClustOfVar \
    corpcor \
    corrr \
    cowplot \
    cranlogs \
    csalert \
    csdata \
    csdb \
    csmaps \
    cstidy \
    cstime \
    csutil

RUN install2.r --error --skipinstalled -n 6 \
    data.table \
    dbplyr \
    DescTools \
    directlabels \
    distill \
    dlnm \
    dlstats \
    drat \
    drc \
    doFuture \
    doSNOW

RUN install2.r --error --skipinstalled -n 6 \
    egg \
    encryptr \
    EnvStats \
    EpiEstim \
    epikit \
    epitrix \
    evaluate

RUN install2.r --error --skipinstalled -n 6 \
    fancycut \
    flextable \
    flux \
    forecast \
    foreach \
    Formula \
    fracdiff \
    future \
    future.callr \
    future.apply

RUN install2.r --error --skipinstalled -n 6 \
    gdtools \
    GeneNet \
    geojsonio \
    ggdendro \
    ggnewscale \
    ggpubr \
    ggrepel \
    ggsurvfit \
    ggthemes \
    ggvis \
    gh \
    git2r \
    glm2 \
    glmnet \
    glmnetUtils \
    globals \
    gower \
    gmailr \
    GPArotation \
    gt \
    gtsummary

RUN install2.r --error --skipinstalled -n 6 \
    HDInterval \
    Hmisc \
    htmlTable \
    htmltools \
    httpuv \
    huxtable

RUN install2.r --error --skipinstalled -n 6 \
    ineq \
    influenceR \
    ISOweek

RUN install2.r --error --skipinstalled -n 6 \
    janitor

RUN install2.r --error --skipinstalled -n 6 \
    kableExtra \
    keras \
    knitcitations \
    knitr

RUN install2.r --error --skipinstalled -n 6 \
    labeling \
    leaflet \
    learnr \
    lemon \
    listenv \
    lme4 \
    lmtest \
    lomb

RUN install2.r --error --skipinstalled -n 6 \
    magick \
    mapproj \
    Matrix \
    MatrixModels \
    matrixStats \
    mclust \
    mem \
    memoise \
    merTools \
    mice \
    miniCRAN \
    missRanger \
    multcomp \
    munsell \
    mvmeta

RUN install2.r --error --skipinstalled -n 6 \
    ncdf4

RUN install2.r --error --skipinstalled -n 6 \
    odbc \
    officer \
    openxlsx \
    org

RUN install2.r --error --skipinstalled -n 6 \
    packrat \
    pacman \
    pander \
    pbapply \
    pbmcapply \
    pbs \
    pkgdown \
    plumber \
    pinp \
    plnr \
    pool \
    pomp \
    postcards \
    ppcor \
    precommit \
    processx \
    profvis \
    progressr \
    pryr \
    pscl \
    PxWebApiData

RUN install2.r --error --skipinstalled -n 6 \
    qs \
    quantmod \
    quarto

RUN install2.r --error --skipinstalled -n 6 \
    RColorBrewer \
    RcppProgress \
    RcppRoll \
    readtext \
    reticulate \
    rio \
    rjtools \
    rmapshaper \
    RMariaDB \
    rmarkdown \
    rms \
    RMySQL \
    RODBC \
    R.oo \
    roxygen2 \
    RPostgres \
    rsvg \
    rticles \
    R.utils

RUN install2.r --error --skipinstalled -n 6 \
    S7 \
    samplingbook \
    scholar \
    selectiveInference \
    shiny \
    shinyBS \
    shinycssloaders \
    shinydashboard \
    skimr \
    sortable \
    splitstackshape \
    staplr \
    styler \
    surveillance \
    survey \
    survminer \
    svglite

RUN install2.r --error --skipinstalled -n 6 \
    table1 \
    tableHTML \
    tensorflow \
    testthat \
    tidyverse \
    tidymodels \
    timeDate \
    tseries \
    TTR

RUN install2.r --error --skipinstalled -n 6 \
    units \
    urca \
    uuid

RUN install2.r --error --skipinstalled -n 6 \
    writexl

RUN install2.r --error --skipinstalled -n 6 \
    xgboost \
    xlsx \
    xts \
    XML

RUN install2.r --error --skipinstalled -n 6 \
    yaml \
    yesno

RUN install2.r --error --skipinstalled -n 6 \
    zip

# rstanarm
RUN R -e "install.packages('rstanarm')"

# INLA
RUN R -e "install.packages('INLA', repos=c(getOption('repos'), INLA='https://inla.r-inla-download.org/R/stable'), dep=FALSE)"
RUN chmod +x /opt/R/$R_VERSION/lib/R/library/INLA/bin/linux/64bit/inla.mkl.run /opt/R/$R_VERSION/lib/R/library/INLA/bin/linux/64bit/inla.mkl

RUN R -e "devtools::install_github(\"csids/csstyle\", upgrade=\"never\", auth_token = \"$GITHUB_PAT\")"
RUN R -e "devtools::install_github(\"csids/cs9\", upgrade=\"never\", auth_token = \"$GITHUB_PAT\")"
RUN R -e "devtools::install_github(\"papadopoulos-lab/swereg\", upgrade=\"never\", auth_token = \"$GITHUB_PAT\")"

####################
# Extra R packages #
####################

RUN R -e "devtools::install_github(\"norsyss/norsyss\", upgrade=\"never\", auth_token = \"$GITHUB_PAT\")"

####################
# CS9 #
####################

# Copy config and startup
COPY content/install_ss_and_run_task.sh /usr/local/bin/install_ss_and_run_task.sh
COPY content/install_ss_and_run_task_k8s.sh /usr/local/bin/install_ss_and_run_task_k8s.sh
RUN chmod +x /usr/local/bin/install_ss_and_run_task.sh
RUN chmod +x /usr/local/bin/install_ss_and_run_task_k8s.sh

RUN R -e "devtools::install_github(\"csids/cs9example\", upgrade=\"never\", auth_token = \"$GITHUB_PAT\")"

####################
# Python libraries #
####################

# reticulate, python, and marrow mailer
RUN echo "RETICULATE_MINICONDA_ENABLED=FALSE" >> $R_HOME/etc/Renviron
RUN echo "RETICULATE_MINICONDA_PATH='/miniconda'" >> $R_HOME/etc/Renviron
RUN echo "RETICULATE_PYTHON='/usr/bin/python3'" >> $R_HOME/etc/Renviron

# https://github.com/marrow/mailer/issues/87
RUN python3 -m pip install --upgrade git+https://github.com/LexMachinaInc/mailer.git
RUN python3 -m pip install --upgrade git+https://github.com/LexMachinaInc/util.git

# https://github.com/lorenzwalthert/precommit
RUN python3 -m pip install --upgrade pre-commit

###########################################################################
# Preparing for later installations of Posit Workbench and RStudio Server #
###########################################################################

COPY content/install_posit.sh /usr/local/bin/install_posit.sh
RUN chmod +x /usr/local/bin/install_posit.sh

#####################
# Fixing ssl issues #
#####################

# https://stackoverflow.com/questions/57265913/error-tcp-provider-error-code-0x2746-during-the-sql-setup-in-linux-through-te
# https://askubuntu.com/questions/1233186/ubuntu-20-04-how-to-set-lower-ssl-security-level
# https://askubuntu.com/questions/1423215/ubuntu-22-04-how-to-set-lower-ssl-security-level
RUN sed -i '1 i\openssl_conf = default_conf' /etc/ssl/openssl.cnf
RUN echo "[ default_conf ]" >> /etc/ssl/openssl.cnf && \
    echo "ssl_conf = ssl_sect" >> /etc/ssl/openssl.cnf && \
    echo "[ssl_sect]" >> /etc/ssl/openssl.cnf && \
    echo "system_default = ssl_default_sect" >> /etc/ssl/openssl.cnf && \
    echo "[ssl_default_sect]" >> /etc/ssl/openssl.cnf && \
    echo "MinProtocol = TLSv1.2" >> /etc/ssl/openssl.cnf && \
    echo "CipherString = DEFAULT:@SECLEVEL=0" >> /etc/ssl/openssl.cnf

#####################
# Airflow
#####################

# Create non-root 'airflow' user with UID 50000 and GID 50000
# Required for Kubernetes Pod Security Standards compliance and principle of least privilege
RUN groupadd -r -g ${AIRFLOW_GID} airflow && \
    useradd -r -u ${AIRFLOW_UID} -g ${AIRFLOW_GID} -s /bin/bash -m airflow

### install Airflow for Kubernetes execution (for Airflow 3.0+ compatibility)
### Use official Airflow 3.1.0 constraints for known-good dependency versions
RUN pip install --upgrade pip && \
    pip install apache-airflow[kubernetes]==3.1.0 \
      --constraint https://raw.githubusercontent.com/apache/airflow/constraints-3.1.0/constraints-3.10.txt && \
    find /usr/local/lib/python3.10/dist-packages -type d -exec chmod 755 {} \; && \
    find /usr/local/lib/python3.10/dist-packages -type f -exec chmod 644 {} \;

### Set AIRFLOW_HOME to /tmp/airflow for ephemeral worker pods
### This allows any UID to import airflow without permission issues
ENV AIRFLOW_HOME=/tmp/airflow

# Ensure airflow user owns necessary directories and can write to them
RUN mkdir -p /tmp/airflow && \
    chown -R airflow:airflow /tmp/airflow && \
    chmod -R 750 /tmp/airflow && \
    chown -R airflow:airflow /opt/airflow 2>/dev/null || true && \
    chmod -R 750 /opt/airflow 2>/dev/null || true

# Switch to non-root airflow user for all subsequent operations
USER airflow

CMD ["R"]



