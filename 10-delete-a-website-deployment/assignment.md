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

👯‍♂️ Why delete is an interesting use case
==============

While your operator can create new website resources, it is completely oblivious to what is going on in the cluster when doing so.

This results in errors whenever the cluster is not in a "prestine" state ready for a new set of website resources.

But all along you have been editing a function called "Reconcile" and that is because your operator is expected to reconcile the difference between requested state (the values in the Website custom resource) and actual state (the current Kuberentes cluster).

In order to handle deletes, you will neeed to first identify that the website resource is requesting a delete, and then read the state of the cluster to reconcile any necessary actions in order to complete that delete.


🧑🏽‍🎓 Learning when a resource should be deleted
==============

You should start by confirming the current state of your



🔥 Deleting from Kuberentes to match requested state
==============


📕 Summary
==============