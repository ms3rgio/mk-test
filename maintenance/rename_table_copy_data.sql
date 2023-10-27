BEGIN;

ALTER TABLE orders RENAME TO orders_old;
ALTER TABLE orders_partitioned RENAME TO orders;

INSERT INTO orders SELECT * FROM orders_old FOR UPDATE;

COMMIT;