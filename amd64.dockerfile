# :: Header
    FROM alpine:3.12
    ENV PGBOUNCER_VERSION=1.15.0

# :: Run
    USER root

    # :: prepare
        RUN mkdir -p \
            /pgbouncer/etc \
            /pgbouncer/run \
            /pgbouncer/log

        RUN addgroup --gid 1000 pgbouncer \
            && adduser --uid 1000 -H -D -G pgbouncer -h /pgbouncer pgbouncer


    # :: install
        ADD http://www.pgbouncer.org/downloads/files/$PGBOUNCER_VERSION/pgbouncer-$PGBOUNCER_VERSION.tar.gz /tmp

        RUN apk --update --no-cache add \
                udns \
                libevent \
                postgresql-client

        RUN apk --update --no-cache --virtual .build add \
                autoconf \
                automake \
                udns-dev \
                gcc \
                libc-dev \
                libevent-dev \
                libtool \
                make \
                openssl-dev \
                pkgconfig \
            && cd /tmp \
            && tar xvfz /tmp/pgbouncer-$PGBOUNCER_VERSION.tar.gz \
            && cd pgbouncer-$PGBOUNCER_VERSION \
            && ./configure --prefix=/usr --with-udns \
            && make \
            && cp pgbouncer /usr/bin \
            && apk del .build \
            && rm -rf /tmp/*                

    # :: copy root filesystem changes
        COPY ./rootfs /

    # :: docker -u 1000:1000 (no root initiative)
        RUN chown -R pgbouncer:pgbouncer /pgbouncer

# :: Volumes
    VOLUME ["/pgbouncer/etc"]

# :: Monitor
    RUN apk --update --no-cache add curl
    RUN chmod +x /usr/local/bin/healthcheck.sh
    HEALTHCHECK CMD /usr/local/bin/healthcheck.sh || exit 1

# :: Start
    RUN chmod +x /usr/local/bin/entrypoint.sh
    USER pgbouncer
    ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
    CMD ["/usr/bin/pgbouncer", "/pgbouncer/etc/pgbouncer.ini"]