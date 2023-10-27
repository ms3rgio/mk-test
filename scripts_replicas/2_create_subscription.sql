CREATE SUBSCRIPTION sub_orders
    CONNECTION 'postgresql://postgres:pg1234@pg-master:5432/testdb'
    PUBLICATION orders_publication;