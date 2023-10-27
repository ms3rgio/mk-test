#!/bin/bash
set -e

begin_at=$(date +%s)

if [ "$#" -ge 1 ] && [ $1 -gt 0 ]; then
  exec_seconds_time=$1
else
  #define a default value of 10 seconds
  exec_seconds_time=10
fi

while [[ $(( $(date +%s) - $begin_at )) -le $exec_seconds_time ]]; do 
  psql -v ON_ERROR_STOP=1 --username postgres --dbname "$POSTGRES_DB" -c "INSERT INTO orders (product_name, quantity, order_date) VALUES ( md5(random()::text), random()*100, '2000-01-01'::date + trunc(random() * 366 * 10)::int);"
  sleep 0.1
done