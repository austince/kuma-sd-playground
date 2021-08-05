#!/usr/bin/env bash

while true; do
  echo "$(date) sending bad request"
  curl http://127.0.0.1:8080/not-a-route 2>/dev/null 1>&2
done
