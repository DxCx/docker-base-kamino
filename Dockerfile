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
RUN mkdir -p /tmp/ && mkdir -p /kamino
WORKDIR /kamino/

# Copy needed files
COPY * ./
RUN chmod +x ./bootstrap.sh && chmod +x ./functions.sh && sync

ENTRYPOINT ["/kamino/bootstrap.sh"]
CMD []
