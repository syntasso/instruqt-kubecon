---
slug: deploy-operator-to-kubernetes
id: kx3btbmriphs
type: challenge
title: Deploy operator to Kubernetes
teaser: It is time running locally, and start deploying to Kubernetes
notes:
- type: text
  contents: |-
    Now that you have a complete operator, it is time to deploy it to Kubernetes!

    While `make run` gives a fast feedback look for development, eventually you will need to deploy your operator to a cluster.

    In this section you will:
    * Build a docker image for your operator
    * Load the docker image into your cluster
    * Generate an operator distribution
    * Deploy the operator distribution into your cluster
tabs:
- title: K8s Shell
  type: terminal
  hostname: kubernetes-vm
  workdir: /root/demo
- title: Run Shell
  type: terminal
  hostname: kubernetes-vm
  workdir: /root/demo
- title: Code editor
  type: service
  hostname: kubernetes-vm
  path: /
  port: 8443
- title: Website
  type: service
  hostname: kubernetes-vm
  path: /
  port: 31000
difficulty: basic
timelimit: 600
---

make docker-build

docker save --output /root/demo/controller-latest.tar controller:latest
k3s ctr images import /root/demo/controller-latest.tar

make distribution

make deploy

📕 Summary
==============
