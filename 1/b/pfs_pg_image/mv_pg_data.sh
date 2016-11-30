#!/bin/bash
set -e
if [ -z ${PGDATA_INPUT_REPO+x} ]; then
  echo '$PGDATA_INPUT_REPO is unset; not moving PostgreSQL data';
else echo "\$PGDATA_INPUT_REPO is set to '$PGDATA_INPUT_REPO'";
  echo "Moving PostgreSQL data from '/pfs/$PGDATA_INPUT_REPO/' to /pfs/out"
  rmdir /pfs/out/
  mv /pfs/$PGDATA_INPUT_REPO/ /pfs/out
fi
