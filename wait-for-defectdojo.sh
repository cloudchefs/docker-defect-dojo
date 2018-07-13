#!/bin/bash

echo "Waiting for defectdojo_one"
until nc -z defectdojo_one 8000
do
  printf "."
  sleep 1
done

echo -e "\ndefectdojo_one ready"
