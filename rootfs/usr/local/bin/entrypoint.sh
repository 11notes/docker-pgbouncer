#!/bin/ash
if env | grep "PG_HOST" -q; then
    sed -i.bak -r "s/host=127.0.0.1/host=${PG_HOST}/" /pgbouncer/etc/pgbouncer.ini
fi
if env | grep "PGBOUNCER_PORT" -q; then
    sed -i.bak -r "s/listen_port = 6432/listen_port = ${PGBOUNCER_PORT}/" /pgbouncer/etc/pgbouncer.ini
fi
exec "$@"