# docker-base-kamino
Kamino is a docker spwaning framework

Notes:
-----------
  - Kamino has a docker engine hosted inside,
    because of that, it must be run using --privileged flag.
  - It is recommended to export /var/lib/docker as mounted volume so images
    that are pulled will be stored on disk.

Kamino Files (Of the child image):
-----------
  - docker-compose.yml - App's docker-compose file.
  - bootstrap.sh       - shell script to run as part of the bootstrap.

Enviorment:
-----------
    KAMINO_INPUT_DIR - directory that will contain current kamino files.
    PUSER - user from docker host to run the services as.
    PUID  - uid of the PUSER
    PGID  - gid of the PUSER

Build:
-----------
    docker build -t base-kamino .
