FROM docker:dind

VOLUME /tmp/

# Decleraing env vars
ENV PUSER nobody
ENV PUID 65534
ENV PGID 65535

# Setting my workdir
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
CMD ["-h"]
