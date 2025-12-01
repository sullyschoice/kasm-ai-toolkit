FROM kasmweb/desktop:1.18.0-rolling-daily
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

######### End Customizations ###########

RUN chown 1000:0 $HOME
RUN $STARTUPDIR/set_user_permission.sh $HOME

ENV HOME=/home/kasm-user
WORKDIR $HOME
RUN mkdir -p $HOME && chown -R 1000:0 $HOME


USER 1000

