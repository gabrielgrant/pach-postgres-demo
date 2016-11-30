# gabrielgrant/pach-postgres-base

Starts a local PostgreSQL server, then launches user scripts. Has hooks to manipulate data before and after PostgreSQL server runs, as well as initial DB setup.


## How to extend this image

There are several ways to use/extend this image.

First, and most obviously, you can run a command. This could be `bash` or psql` which then gets fed the proper input on `stdin`

If you would like to do additional initialization in an image derived from this one, add one or more *.sql or *.sh scripts under one of the entrypoint extension directories (in order of execution):


- `/pach-entrypoint-setup.d` At the beginning of the entrypoint, before database initialization, this extension point allows you to configure/move PostgreSQL's data files
- `/docker-entrypoint-initdb.d` After the entrypoint calls `initdb` to create the default `postgres` user and database, it this extension point allows further initialization before starting the main service.
- `/pach-entrypoint-main.d` Once the database has started up for external access, these scripts will be run, followed immediately by any `CMD` defined
- `/pach-entrypoint-teardown.d` After the PostgreSQL server has been stoped, this extension point allows you to perform any needed cleanup.

The image will run any *.sql files and source any *.sh scripts found each directory at the appropriate time in the container's lifecycle
