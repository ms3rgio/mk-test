BEGIN;

ALTER TABLE orders RENAME TO orders_old;
ALTER TABLE orders_partitioned RENAME TO orders;

INSERT INTO orders SELECT * FROM orders_old FOR UPDATE;

SELECT max(id) as orders_old_max_id from orders_old \gset

ALTER TABLE orders ALTER column id SET START :orders_old_max_id;

COMMIT;