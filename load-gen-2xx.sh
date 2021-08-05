#!/usr/bin/env bash

while true; do
  echo "$(date) sending request"
  curl http://127.0.0.1:8080/items?q= 2>/dev/null 1>&2
  curl http://127.0.0.1:8080/items/1/reviews 2>/dev/null 1>&2
done
