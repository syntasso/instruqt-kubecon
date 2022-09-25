---
slug: delete-a-website-deployment
id: uocpjfaybikk
type: challenge
title: Delete a website deployment
teaser: The power of operators is handling any drift between requested state and cluster
  state, in this section learn how to detect deletion drift and execute on it
notes:
- type: text
  contents: |-
    Create Read Update and Delete (CRUD) is considered basic functionality for most applciations and an operator is no different.

    So far you have created a deployment and service, but have yet to read, update or delete.

    In this section you will:
    * Detect the deletion of a website by reading current state
    * Delete any resources the operator creates when it's CRD is deleted
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

delete

see deployment still there

handle delete

📕 Summary
==============