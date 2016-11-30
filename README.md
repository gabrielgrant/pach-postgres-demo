kubectl exec postgres -it -- psql -U postgres

bash <(wget -qO- https://github.com/gabrielgrant/pach-postgres-demo/blob/master/launch-XXX.sh?raw=true)




There are several options for how to integrate with PG data




## 1. Dump to Pachyderm, Process, then Load

The most "pure" way to analyze data with Pachyderm today is to have it handle the data storage and analysis end-to-end. This likely means regularly dumping a live database, importing that data dump into the Pachyderm FileSystem (PFS), doing the processing all within Pachyderm Pipeline System (PPS) code, and then exporting the output data back into whatever system needs to consume these results.

If the database is currently being used a simple data store, with client code loading data, performing analysis locally, and then dumping results back to the DB, this may be a fairly simple change. If there are more advanced database features being used to perform analysis or mutation of the data, converting to use a Pachyderm-only process could require significant reworking of the existing codebase.


## 2. PG Running in Pachyderm

The simplest approaches involve running Postgres within Pachyderm itself. The upside is simplicity, and that everything is "within the system". The downside is that this entails potentially-significant data transfer overhead[1] and either some wasted processing time to dump & reload data at each stage (option #1.A), or some wasted storage space due to completely duplicated dumps (option #1.B)[2].

[1]: Especially if a given processing stage only uses a small portion of the data in the database
[2]: Option #1.B also almost assuredly results in meaningless diffs, even, likely, for append-only scenarios. That's not really an issue at the moment, though, since diffs aren't currently used directly

### A. `COPY FROM` / `TO`

### B. Put the whole PGDATA directory in PFS

copy from /pfs/in to /pfs/out before starting the PG server & running analysis

Note: this seems to me like the best option in most cases ATM


## 3. PG Running Outside Pachyderm

A more optimized option is to run one (or several) PG servers outside of Pachyderm, likely as a service on Kubernetes. The first pipeline creates a new logical database with unique ID, and loads the input data. When done it's analysis, it outputs that database's ID for the next pipeline stage to start.

The difference is in how the raw data makes it's way from PG to Pachyderm for long-term storage/versioning.

### A. In-pipeline PG Dump

The simpler option is for a given pipeline stage to dump it's own data as well as output the ID of the database. This allows the next stage to begin processing without having to load/reindex the data.

### B. Sub-pipeline PG Dump

A more complex option is to have a given pipeline stage only output the unique DB ID, and have that trigger both the next stage of processing, as well as a separate pipeline who's sole purpose is to dump the data. This allows the next stage to begin processing the pre-loaded/-indexed data without waiting for a dump to complete.

In order to safeguard against a subsequent 


## 4. Log storage alternative

An entirely different approach would be to store the full stream of SQL commands 

This approach would be usable regardless of whether the PG DB is inside or outside of pachyderm

The new `pg_logical` may have some optimizations for only storing the raw transformed data rather than the full operation that caused the data transform (uncertain, TBD)





## Example: Pete's Peanuts

Pete the Parakeet has built an online nut delivery empire, but wants better visibility into how his sales are going. We're going to dump his production DB, load it into PostgreSQL for analysis, and output a daily generated report.





