---
slug: generate-new-controller-and-custom-resource
id: adhjrg6fqgds
type: challenge
title: Generate a new controller and custom resource
teaser: Use Kubebuilder to generate an controller and corresponding custom resource
  (CRD) for your new business.
notes:
- type: text
  contents: |-
    Kubebuilder has generated a Golang application, but it is time to now build your business case in.



    **In this challenge you will:**
    * Be introduced to the example business case
    * Create a controller and custom resource (CRD) using Kubebuilder
tabs:
- title: K8s Shell
  type: terminal
  hostname: kubernetes-vm
  workdir: /root/demo
- title: Code editor
  type: service
  hostname: kubernetes-vm
  path: /
  port: 8443
difficulty: basic
timelimit: 600
---

🐾 Dreaming of a better todo app
==============

While you already have a working Golang application, it is time to add some business logic to create a useful (albeit, simple) operator.

In this case, imagine you want to create a better todo application experience.

You have already packaged your perfected user experience as a container image and want to now make it ready for the world. You are well versed in how maintenance can create a lot of [toil](https://sre.google/sre-book/eliminating-toil/) and want to make sure that your deployment choices automate as much of the operations of this site as possible.

To do this, you have settled on deploying to Kubernetes and want to do so via an operator. To get started, your plan is to support:

* When a website does not yet exist in a cluster, _**create**_ a new one
* Acknowledging when a request will _**update**_ an existing website
* _**Delete**_ a website upon request

You realise there are a lot more things that you will want to operate in the future (e.g. moving to remote storage, storage backups) but these lifecycle tasks will set a foundation for a more complex operator to succeed.


👩🏾‍💻 First, create the controller and resource
==============

Kubebuilder provides a command that can create either (or both) the `Controller` application and a new `Resource` type.

Since every controller needs to respond to events of certain resources, if you choose to create these at the same time, Kubebuilder also automatically configures the controller to run when any resources of the new type are created, changed, or deleted.

> 💡 If you do not create both at the same time, you will need to manually configure what resources the controller will react to.

Today you will create both at the same time allowing Kubebuilder to complete the autoconfiguration by running the following command in your `K8s Shell` tab:

```
kubebuilder create api \
  --kind Website \
  --group kubecon \
  --version v1beta1 \
  --resource true \
  --controller true
```

The next two challenges will dive into what these two items actually create in your code base and how they work together to operate your todo application.


📕 Summary
==============

Congratulations, you have officially generated your first operator!

At this stage, Kubebuilder has wired up two key components for your operator:

1. A Resource in the form of a Custom Resource Definition (CRD) with the kind `Website`.
2. A Controller that runs each time a `Website` CRD is create, changed, or deleted.

Next up, you will explore these two components in more detail.
