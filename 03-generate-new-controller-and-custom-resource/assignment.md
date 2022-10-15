---
slug: generate-new-controller-and-custom-resource
id: adhjrg6fqgds
type: challenge
title: Generate a new controller and custom resource
teaser: Use Kubebuilder to generate a controller and corresponding custom resource
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
timelimit: 1
---

☑️ Dreaming of a better todo app
==============

While you already have a working Golang application, it is time to add some business logic to create a useful (albeit, simple) operator.

In this case, imagine you want to create a better todo application experience (based on [this code](https://github.com/hariramjp777/frontend-todo-app) by [Hari Ram](https://dev.to/hariramjp777)). You have your website application ready to deploy as a container image, and you want to now make it ready for the world. 

You are well versed in how maintenance can create a lot of [toil](https://sre.google/sre-book/eliminating-toil/) so you want to make sure that your deployment choices automate as much of the operations of this site as possible.

To reduce toil for this application, you will create a Kubernetes operator. As the first phase of functionality, this operator will:

* _**create**_ a new instance of the website in a cluster if the cluster does not already have one
* _**acknowledge**_ when a request will update an existing website instance
* _**delete**_ a website instance upon request

There are a lot more things that you will want to automate in the future (e.g. moving to remote storage, storage backups), but this first release of your operator sets the foundation for future complexity.

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
