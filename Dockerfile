# Kasm base image tag. Images built on 1.20+ bases do not run on Kasm 1.19 and older.
#   1.19.0-rolling-daily -> Kasm 1.19 and older (default)
#   develop              -> Kasm 1.20 (until a 1.20 rolling base tag is published)
ARG BASE_TAG=1.19.0-rolling-daily

FROM kasmweb/core-ubuntu-noble:${BASE_TAG}
USER root

ENV HOME=/home/kasm-default-profile
ENV STARTUPDIR=/dockerstartup
ENV INST_SCRIPTS=$STARTUPDIR/install
WORKDIR $HOME

######### Customize Container Here ###########

COPY ./src/ai-toolkit $INST_SCRIPTS/ai-toolkit/
RUN bash $INST_SCRIPTS/ai-toolkit/install_ai-toolkit.sh  && rm -rf $INST_SCRIPTS/ai-toolkit/

COPY ./src/ai-toolkit/custom_startup.sh $STARTUPDIR/custom_startup.sh
RUN chmod +x $STARTUPDIR/custom_startup.sh
COPY ./src/ai-toolkit/launcher.sh /opt/ai-toolkit/launcher.sh
RUN chmod +x /opt/ai-toolkit/launcher.sh
RUN chown 1000:1000 /opt/ai-toolkit/launcher.sh
COPY ./src/ai-toolkit/ai-toolkit.png /opt/ai-toolkit/ai-toolkit.png
RUN chown 1000:1000 /opt/ai-toolkit/ai-toolkit.png

RUN apt-get update && apt-get install -y nomacs gimp vlc

RUN cd /tmp && \
 curl -L \
 https://raw.githubusercontent.com/kasmtech/workspaces-images/refs/heads/develop/src/ubuntu/install/chrome/install_chrome.sh  -o install_chrome.sh && \
 bash ./install_chrome.sh && \
 rm ./install_chrome.sh

######### End Customizations ###########

RUN chown 1000:0 $HOME
RUN $STARTUPDIR/set_user_permission.sh $HOME

ENV HOME=/home/kasm-user
WORKDIR $HOME
RUN mkdir -p $HOME && chown -R 1000:0 $HOME


USER 1000
