#!/usr/bin/env bash

kubectl port-forward -n monitoring svc/prometheus-server 9090:80
