FROM docker:dind

# TODO: Why tmp has to be a volume
VOLUME ["/tmp/"]
VOLUME ["/var/lib/docker/"]

# Decleraing env vars
#ENV KAMINO_INPUT_DIR
ENV PUSER nobody
ENV PUID 65534
ENV PGID 65535

# Setting my temp & workdir
RUN mkdir -p /tmp/
RUN mkdir -p /kamino/
WORKDIR /kamino/

# TODO: Modify docker images path.

# Copy needed files
COPY docker-compose.yml ./
COPY bootstrap.sh ./
RUN chmod +x ./bootstrap.sh && sync
COPY functions.sh ./
RUN chmod +x ./functions.sh && sync

ENTRYPOINT ["/kamino/bootstrap.sh"]
CMD []
