# `kuma_sd` Playground

A small example of using Promethues's Kuma SD to securely monitor services.

## Contents

* Three namespaces, `kuma-system`, `monitoring`, and `kuma-demo` (in [`./namespaces`](namespaces))
  * `kuma-system` is the Kuma Control Plane's "system" namespace
  * `monitoring` and `kuma-demo` are for workloads, and configured to let Kuma inject a Dataplane Proxy Sidecar (Envoy) to all pods
* Kuma 1.2.3 Control Plane (in [`./kuma-control-plane`](kuma-control-plane))
  * One `Mesh` with mTLS enabled
  * A `TrafficPermission` to allow all services to talk to all services
* Prometheus (in [`./prometheus`](prometheus)), configured to discover targets from Kuma
* The Kuma Demo App (in [`./demo-app`](demo-app)), source found at: https://github.com/kumahq/kuma-demo/


### Prometheus Configuration

See [`./prometheus/config.yaml`](prometheus/config.yaml) and take note of the `kuma-dataplane` job's `relabel_config`, 
which attaches discovered labels to each metric via [relabelling](https://prometheus.io/docs/prometheus/2.29/configuration/configuration/#relabel_config). 

Full Reference: https://prometheus.io/docs/prometheus/2.29/configuration/configuration/#kuma_sd_config

## Setup

```shell
kubectl apply -f namespaces/

kubectl apply -f kuma-control-plane/

# Must wait for the control-plane to come up so it can inject the Kuma Dataplane Sidecar
kubectl wait --for=condition=ContainersReady --namespace kuma-system pods --all
 
kubectl apply -f prometheus/

kubectl apply -f kuma-policies/

kubectl apply -f demo-app/
```

## View

```shell
# In different shells:

# Access Prometheus UI at localhost:9090
./port-forward-prometheus.sh

# Access Kuma UI at localhost:5681/gui
./port-forward-kuma-control-plane.sh

# Access Demo App UI at localhost:8080
./port-forward-demo.sh

# Create some traffic on the network to generate both HTTP 2xx and 4xx responses 
./load-gen-2xx.sh
./load-gen-4xx.sh
```

Prometheus should start actively scraping the services and ingesting the exported
Envoy (the Dataplane Proxy) metrics.

In the Prometheus UI, check out:
* Status > Service Discovery
  * Expand the `kuma-dataplanes` job to see all the services and discovered labels.
  These discovered labels are all available for the `relabel_config` stanza of the Prometheus config.
* Status > Targets
  * Expand the `kuma-dataplanes` job to see the scraped endpoints and the exposed labels.
* Graph
  * Try the PromQL query `envoy_cluster_upstream_rq_xx{app="frontend"}` to see 
  request code groupings from the Frontend service to all others.
  * To dig further into available metrics, start with: https://www.envoyproxy.io/docs/envoy/latest/configuration/upstream/cluster_manager/cluster_stats#dynamic-http-statistics


## Teardown

```shell
kubectl delete -f demo-app/

kubectl delete -f kuma-policies/

kubectl delete -f prometheus/

kubectl delete -f kuma-control-plane/

kubectl delete -f namespaces/
```
