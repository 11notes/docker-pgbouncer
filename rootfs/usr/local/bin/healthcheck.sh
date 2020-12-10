#!/bin/ash
DOCKER_HEALTH__PORT="6432"
if env | grep "PGBOUNCER_PORT" -q; then
    DOCKER_HEALTH__PORT="${PGBOUNCER_PORT}"
fi
pg_isready -h 127.0.0.1 -p $DOCKER_HEALTH__PORT