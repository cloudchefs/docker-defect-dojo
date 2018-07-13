#!/bin/bash

echo "Waiting for mysql"
until mysql -h"db" -P"3306" -uroot -p"admin" &> /dev/null
do
  printf "."
  sleep 1
done

echo -e "\nmysql ready"
