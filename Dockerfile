FROM i386/alpine:3.20

RUN apk update && \
    apk add \
        bash \
        dumb-init \
        libarchive-tools \
        logtail \
        tzdata \
        wget \
        wine \
        xvfb-run

ENV TZ=Europe/Moscow

RUN wineboot -i

WORKDIR /srv
ADD ./ ./

ARG archive=NFK-dedicated.zip
RUN wget https://github.com/NeedForKillTheGame/needforkill.ru/releases/download/server/$archive && \
    bsdtar --strip-components=1 -xvf $archive && \
    rm -f $archive

ARG modelDir=/srv/basenfk/models
ARG modelList="arctic crashed doom2 grunt halo keel klesk2 qforcer ranger rawsteel razor sorlag tankjr uriel2 utguyse visor xaero"
RUN for m in $modelList; do ln -s $modelDir/sarge $modelDir/$m; done 

HEALTHCHECK --start-period=30s --start-interval=15s --interval=30s --retries=2 CMD ./healthcheck.sh || kill 1

EXPOSE 29991/udp
EXPOSE 28991/tcp

ENTRYPOINT ["/usr/bin/dumb-init", "--", "./entrypoint.sh"]
CMD ["Server_MG3.exe"]
