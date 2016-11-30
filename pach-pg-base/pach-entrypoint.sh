#!/bin/bash
set -e

# taken from https://github.com/docker-library/postgres/blob/master/9.6/docker-entrypoint.sh
# usage: file_env VAR [DEFAULT]
#    ie: file_env 'XYZ_DB_PASSWORD' 'example'
# (will allow for "$XYZ_DB_PASSWORD_FILE" to fill in the value of
#  "$XYZ_DB_PASSWORD" from a file, especially for Docker's secrets feature)
file_env() {
	local var="$1"
	local fileVar="${var}_FILE"
	local def="${2:-}"
	if [ "${!var:-}" ] && [ "${!fileVar:-}" ]; then
		echo >&2 "error: both $var and $fileVar are set (but are exclusive)"
		exit 1
	fi
	local val="$def"
	if [ "${!var:-}" ]; then
		val="${!var}"
	elif [ "${!fileVar:-}" ]; then
		val="$(< "${!fileVar}")"
	fi
	export "$var"="$val"
	unset "$fileVar"
}



echo
echo 'Running setup.'
echo
for f in /pach-entrypoint-setup.d/*; do
	case "$f" in
		*.sh)     echo "$0: running $f"; . "$f" ;;
		*.sql)    echo "$0: running $f"; "${psql[@]}" < "$f"; echo ;;
		*.sql.gz) echo "$0: running $f"; gunzip -c "$f" | "${psql[@]}"; echo ;;
		*)        echo "$0: ignoring $f" ;;
	esac
	echo
done

echo
echo 'Starting PostgreSQL in background mode.'
echo

if [ "${1:0:1}" = '-' || "$1" = "postgres" ]; then
	/docker-entrypoint.sh "$@" &
else
  /docker-entrypoint.sh 'postgres' &
fi

file_env 'POSTGRES_USER' 'postgres'
file_env 'POSTGRES_DB' "$POSTGRES_USER"

psql=( psql -v ON_ERROR_STOP=1 --host=$POSTGRES_SERVICE_HOST --port=$POSTGRES_SERVICE_PORT --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" )



TIMEOUT=30

until "${psql[@]}" -c "select 1" > /dev/null || [ $TIMEOUT -eq 0 ]; do
  echo "Waiting for postgres server, $((TIMEOUT--)) remaining attempts..."
  sleep 1
done

echo

if [  $TIMEOUT -eq "0" ]; then
  echo
  echo "Timeout: Failed to connect to PostgreSQL server"
  exit -1
fi

echo
echo 'PostgreSQL startup complete; running main.'
echo
for f in /pach-entrypoint-main.d/*; do
	case "$f" in
		*.sh)     echo "$0: running $f"; . "$f" ;;
		*.sql)    echo "$0: running $f"; "${psql[@]}" < "$f"; echo ;;
		*.sql.gz) echo "$0: running $f"; gunzip -c "$f" | "${psql[@]}"; echo ;;
		*)        echo "$0: ignoring $f" ;;
	esac
	echo
done


# run user-defined CMD

if [ "${1:0:1}" != '-' && "$1" != "postgres" ]; then
	"$@"
fi

echo
echo 'Execution complete; shutting down PostgreSQL.'
echo

gosu postgres pg_ctl -D "$PGDATA" -m fast -w stop


echo
echo 'PostgreSQL shutdown complete; running user teardown.'
echo
for f in /pach-entrypoint-teardown.d/*; do
	case "$f" in
		*.sh)     echo "$0: running $f"; . "$f" ;;
		*.sql)    echo "$0: running $f"; "${psql[@]}" < "$f"; echo ;;
		*.sql.gz) echo "$0: running $f"; gunzip -c "$f" | "${psql[@]}"; echo ;;
		*)        echo "$0: ignoring $f" ;;
	esac
	echo
done
