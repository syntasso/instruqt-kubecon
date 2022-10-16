---
slug: generate-new-operator-and-custom-resource
id: adhjrg6fqgds
type: challenge
title: Generate a new operator and custom resource
teaser: Use Kubebuilder to generate a operator and corresponding custom resource (CRD)
  for your new business.
notes:
- type: text
  contents: |-
    Kubebuilder has generated a Golang application, but it is time to now build your business case in.

    **In this challenge you will:**
    * Be introduced to the example business case
    * Create a operator and custom resource (CRD) using Kubebuilder
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

☑️ Dreaming of a better to-do app
==============

So you have a working Golang application. Now it is time to add some business logic to create a useful (albeit, simple) operator.

In this case, imagine you have created a to-do application and want to deploy a number of custom versions of it (based on [this code](https://github.com/hariramjp777/frontend-todo-app) by [Hari Ram](https://dev.to/hariramjp777)). 

You have already packaged your website application as a container image and now you want to deploy the first version of it.

You are well versed in how maintenance can create a lot of [toil](https://sre.google/sre-book/eliminating-toil/). You want to make sure that your deployment choices automate as much of the operations as possible.

To reduce toil for this application, you will create a Kubernetes operator. As the first phase of functionality, this operator will:

* _**create**_ a new instance of the todo application as a website in a cluster if the cluster does not already have one
* _**update**_ when the request changes in a known way
* _**delete**_ a website instance upon request

Of course there are a lot more things that you will want to automate in the future (e.g. moving to remote storage, storage backups). But this first release of your operator sets the foundation for future complexity.

👩🏾‍💻 First, create the operator and resource
==============

Kubebuilder provides a command that can create either the `Controller` process or a new `Resource` type (or both!).

Remember, every operator responds to events of certain resource types. In this case, you are creating a custom type (called `Website`). If you choose to create your custom type at the same time as your operator, Kubebuilder automatically configures the operator to know about the type.

> 💡 If you do not create both at the same time, you will need to manually configure the operator to know what resources to track.
Today you will create both at the same time allowing Kubebuilder to complete the auto-configuration. Create these by running the following command in your `K8s Shell` tab:

```
kubebuilder create api \
  --kind Website \
  --group kubecon \
  --version v1beta1 \
  --resource true \
  --controller true
```
The next two challenges will dive into what these two items actually create in your code base and how they work together to operate your to-do application.


📕 Summary
==============

Congratulations, you have officially generated your first operator!

At this stage, Kubebuilder has wired up two key components for your operator:

1. A Resource in the form of a Custom Resource Definition (CRD) with the kind `Website`.
2. A Controller that runs each time a `Website` CRD is create, changed, or deleted.

Next up, you will explore these two components in more detail.
