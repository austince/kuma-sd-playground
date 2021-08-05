#!/usr/bin/env bash

kubectl port-forward svc/kuma-control-plane -n kuma-system 5681:5681 5676:5676
