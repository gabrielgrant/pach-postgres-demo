FROM postgres:9.6
MAINTAINER Gabriel Grant <g@briel.ca>

COPY pach-entrypoint.sh /

RUN mkdir /pach-entrypoint-setup.d && mkdir /pach-entrypoint-main.d && mkdir /pach-entrypoint-teardown.d

ENTRYPOINT ["/pach-entrypoint.sh"]
