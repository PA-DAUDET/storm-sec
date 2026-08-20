FROM eclipse-temurin:25-jre

# Variables d'environnement
ENV STORM_CONF_DIR=/conf \
    STORM_DATA_DIR=/data \
    STORM_LOG_DIR=/logs \
    STORM_HOME=/opt/storm

# Paramètre de version (modifiable au build)
ARG STORM_VERSION=3.0.1-SNAPSHOT

# Remove the default user 'ubuntu' and its group
RUN userdel -r ubuntu && \
    groupdel ubuntu || true \

# Add a user with an explicit UID/GID and create necessary directories
RUN set -eux; \
    groupadd -r storm --gid=1000; \
    useradd -r -g storm --uid=1000 -m -d /home/storm storm; \
    mkdir -p "$STORM_CONF_DIR" "$STORM_DATA_DIR" "$STORM_LOG_DIR" "$STORM_HOME"; \
    chown -R storm:storm "$STORM_CONF_DIR" "$STORM_DATA_DIR" "$STORM_LOG_DIR" "$STORM_HOME"

# Install required packages
RUN set -eux; \
    apt-get update; \
    DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
        bash \
        ca-certificates \
        dirmngr \
        gosu \
        gnupg \
        python3 \
        procps \
        wget \
        curl; \
    rm -rf /var/lib/apt/lists/*; \
    gosu nobody true

# Copier la distribution locale compilée (avec version paramétrée)
COPY storm-dist/binary/final-package/target/apache-storm-${STORM_VERSION}.tar.gz /tmp/

# Extraire dans /opt/storm
RUN set -eux; \
    tar -xzf /tmp/apache-storm-${STORM_VERSION}.tar.gz -C /opt; \
    mv /opt/apache-storm-${STORM_VERSION}/* $STORM_HOME/; \
    rm -rf /opt/apache-storm-${STORM_VERSION}; \
    rm /tmp/apache-storm-${STORM_VERSION}.tar.gz; \
    mkdir -p $STORM_HOME/logs; \
    chown -R storm:storm $STORM_HOME

ENV PATH=$PATH:$STORM_HOME/bin

WORKDIR /home/storm

# Copy entrypoint script
COPY docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["storm", "help"]

EXPOSE 6627 8080 6700 6701 6702 6703