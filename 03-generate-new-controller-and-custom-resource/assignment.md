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



    In this challenge you will:
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

🐾 Dreaming of a pet smile website
==============

While you already have a working golang application, it is time to add some business logic to create a useful (albeit, simple) operator.

In this case, imagine you want to run a website to bring the joy of pet smiles to the world and want to start with a website of dog smiles.

You have already packaged your perfected website as a container image and want to now make it ready for the world. You are well versed in how maintenance can create a lot of [toil](https://sre.google/sre-book/eliminating-toil/) and want to make sure that your deployment choices automate as much of the operations of this site as possible.

To do this, you have settled on deploying to Kubernetes and want to do so via an operator. To get started, your plan is to support:

* When a website does not yet exist in a cluster, **create** a new one
* Acknowledging when a request will **update** an existing website
* **Deleting** a website upon request

You realise there are a lot more things that you will want to operate in the future (e.g. backups) but these lifecycle tasks will set a foundation for a more complex operator to succeed.


👩🏾‍💻 First, create a controller and corresponding Resource type
==============

Kubebuilder provides a command that can create either (or both) the `Controller` application and a new `Resource` type.

Since every controller needs to respond to events of certain resources, if you choose to create these at the same time, Kubebuilder also automatically configures the controller to run when any resources of the new type type emit an event. If you do not create both at the same time, you will need to manually configure what resources the controller will react to.

Today you will create both at the same time allowing Kubebuilder to complete the autoconfiguration by running the following command in your `K8s Shell` tab:

```
kubebuilder create api \
  --kind Website \
  --group kubecon \
  --version v1beta1 \
  --resource true \
  --controller true
```

The next two challenges will dive into what these two items actually create in your code base and how they work together to operate your dog smile website.


📕 Summary
==============

Congratulations, you have officially generated your first operator!

At this stage, Kubebuilder has wired up two key components for your operator:

1. A Resource in the form of a Custom Resource Defintion (CRD) with the kind `Website`.
2. A Controller that runs each time a `Website` CRD is create, changed, or deleted.

Next up, you will explore these two components in more detail.
