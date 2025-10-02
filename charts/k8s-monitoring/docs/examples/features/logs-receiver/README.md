<!--
(NOTE: Do not edit README.md directly. It is a generated file!)
(      To make changes, please modify values.yaml or description.txt and run `make examples`)
-->
# Profiles Receiver

This example demonstrates how to enable the Logs Receiver feature to receive logs from applications on your
Kubernetes cluster, process them according to defined rules, and then deliver them to Loki.

## Values

<!-- textlint-disable terminology -->
```yaml
---
cluster:
  name: logs-receiver-cluster

destinations:
  - name: loki
    type: loki
    url: http://loki.loki.svc

logsReceiver:
  enabled: true

alloy-receiver:
  enabled: true
```
<!-- textlint-enable terminology -->
