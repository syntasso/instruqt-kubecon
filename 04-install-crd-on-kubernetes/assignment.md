---
slug: install-crd-on-kubernetes
id: zolv3abe59us
type: challenge
title: Install the new CRD on Kubernetes
teaser: Explore the Kubebuilder generated CRD and then install it on your Kubernetes
  cluster.
notes:
- type: text
  contents: |-
    In the previous challenge you created a controller and resource (CRD). Now is your chance to explore the resource CRD!

    In this challenge you will:
    * Understand how the CRD is represented in Golang code
    * Transorm the code CRD to a yaml CRD ready to be installed in Kubernetes
    * Install the CRD using the provided `make` commands
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
timelimit: 360
---

🧬 Viewing the generated CRD code
==============

By selecting to create a Resource in the previous step, you have generated a Custom Resource Definition (CRD).

This CRD is first written in Golang code found in your `Code editor` tab under `api` > `v1beta1` > `website_types.go`.

You may not be familiar with Golang, but that is OK.

Have a look in the document for the `type WebsiteSpec`. Think of this as the code definiton of the Kubernetes object `spec`.

You can see here in `api/v1beta1/website_types.go:32` that there is a field called `foo` and there is a helpful comment above it describing the use of `foo`.

The reason this is defined first in Golang is to allow reference from the Golang controller. However, for this CRD to be installed in Kubernetes, it needs to be in yaml format. Continue on to see how that is created.


👩🏾‍💻 Creating a yaml version
==============

In order to install this CRD into the Kubernetes cluster, it needs to be in yaml format. Before running anything, have a look in `config` > `crd` and see that currently there is no directory called `bases`. This is where the yaml will be written to once it is generated.

The `install` make target handles all this heavy lifting through its prerequisite targets.But remember that each time you run `make install`, it will start by running all of its prerequisites. In the case of `install`, this is the full chain as described in the `Makefile:86`:

> install: manifests kustomize

Now you can run just the prerequisite target `manifests` manually to understand that this is where the Golang is translated into yaml:

```
make manifests
```

Return to the `Code editor` tab to see a new file populated in the `bases` directory you previously did not see. Find the field `foo` in this yaml to see how it has been translated from Golang.

In particular, look at `config/crd/bases/kubecon.my.domain_websites.yaml:37` and you will see that there is a single property of the `WebsiteSpec` schema. That property is `foo` and it has used the helpful comment as a property description.

Now it is time to actually put this CRD into your Kubernetes cluster.


🚀 Installing the CRD into your Kubernetes cluster
==============

While you can manually apply the previously generated YAML, Kubebuilder provides a make target to codify the further configuration of the yaml with [Kustomize](https://kustomize.io/) as well as the application of the yaml to Kubernetes.

To see current state, start by viewing all current CRDs in the Kubernetes cluster by running the following command in the `K8s Shell` tab:

```
kubectl get crds
```

As you can see that while there are other CRDs installed, website is not on the list.

Now run the make command to install your new website CRD:

```
make install
```

If you `kubectl get crds` again, you will see the `websites.kubecon.my.domain` listed there at the bottom of the list.


📕 Summary
==============

After this challenge you have successfully installed a new Custom Resource Definition onto your Kubernetes cluster.

Soon you will request an instance of this but first, you will get to dig into the controller that you created alongside this CRD.
