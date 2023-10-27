# ck-test

## How to execute

```sh 
docker compose up -d
```

At startup we will already create the `orders` table, configure replication and insert some data.
You can see the data by running it:

```sh
docker exec -it pg-master psql -U postgres -d testdb -c "table orders;"
```

## Validate replication

We can insert some more data into the `pg-master`:

```sh
docker exec -it pg-master /docker-entrypoint-initdb.d/3_app.sh 10
```

And then compare the number of records between `pg-master` and `pg-replica`. Both should return the same number:

```sh
docker exec -it pg-master psql -U postgres -d testdb -c "select count(*) from orders;"
docker exec -it pg-replica psql -U postgres -d testdb -c "select count(*) from orders;"
```

## Stop replication

Let's stop replication to partition the `orders` table

```sh
docker exec -it pg-replica psql -U postgres -d testdb -f /maintenance/drop_subscription.sql
docker exec -it pg-master psql -U postgres -d testdb -f /maintenance/drop_publication.sql
```

## Table partition

First we need to create a new partitioned table and also create its partitions

```sh
docker exec -it pg-master psql -U postgres -d testdb -f /maintenance/create_table_orders_partitions.sql
```

As an example, I'm partitioning by month and creating only the partitions for the year 2023, in addition to the default partition. In the production environment, the ideal is to create a routine to automate the creation of these partitions

Let's run our script again to insert new data and run the partitioning without downtime:

```sh
docker exec -it pg-master /docker-entrypoint-initdb.d/3_app.sh 180
```

This way the script will run for 3 minutes (180 seconds). Open another terminal to continue.

Now that the structure is ready, we can copy the data to the partitioned orders table.

```sh
docker exec -it pg-master psql -U postgres -d testdb -f /maintenance/rename_table_copy_data.sql
```

Here we are using `... SELECT ... FOR UPDATE ` command to copy the data. This ensures that the data is not modified during copying, but it also causes the table to be locked for writing and should only be used in test environments.  

For production environments we should use other alternatives such as triggers and copy-batch together or even replication.

## Destroy everything

```sh
docker compose down -v
```

