#!/usr/bin/env bash

kubectl port-forward svc/frontend -n kuma-demo 8080:8080
