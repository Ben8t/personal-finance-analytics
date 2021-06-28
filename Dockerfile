FROM rocker/tidyverse

RUN mkdir -p /home/user/.rstudio/monitored/user-settings/

RUN apt-get update &&  \
    apt-get install -y libmagick++-dev \
    apt-get install -y libsodium-dev


RUN R -e "install.packages('ggdist', dependencies=TRUE, repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('ggtext', dependencies=TRUE, repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('keyring', dependencies=TRUE, repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('blastula', dependencies=TRUE, repos='http://cran.rstudio.com/')"

RUN cd /usr/share/fonts && git clone https://github.com/Ben8t/fonts.git
RUN fc-cache -f -v

COPY plot .
COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

