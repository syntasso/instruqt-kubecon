---
slug: get-to-know-the-platform
id: yzq8tbn8srib
type: challenge
title: Get to know the platform
teaser: Explore how this course is being delivered in the browser, but has all the
  power of your laptop
notes:
- type: text
  contents: |-
    This track uses a single node Kubernetes cluster on a sandbox virtual machine.
    Please wait while we boot the VM for you and start Kubernetes. Once the VM
    is ready you will see a green start bottom in the right hand corner.

    There are a number of slides with corresponding hands on activities, these are each called "sections"

    In this first section, you will:
    - Get comfortable with this online environment
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

👋🏾 Introduction
==============

Welcome to your personal Kuberentes cluster! 🏡

You can see two tabs on the top left. One named `K8s Shell` tab and the other `Code editor`.

Throughout this course you will use `K8s Shell` to interact with your Kuberentes (K8s) cluster.

To see how this works, try running the following command:

```
kubectl get namespaces
```

> 💡 You can copy this command by clicking anywhere in the text box and then paste it into the terminal

And in the `Code editor` tab you can create and edit files in a VS Code style environment. To see how this works, click on the `Code editor` tab and navigate to the file `.example-namespace.yaml`

The following code configures a new namespace in Kubernetes. Paste this code in the file:

```
---
apiVersion: v1
kind: Namespace
metadata:
  name: example
```

Now return to the `K8s Shell` tab and apply this file to your cluster using the following command:

```
kubectl apply \
  --filename .example-namespace.yaml
```

You can confirm your namespace has been created by running the get namespaces command again.

📕 Summary
==============

Congratulations! You have know navigated your way around the platform and are ready to create your first operator.

> 💡 One last tip: When you are done with a section, click on the header to minimize and make more space for the next section. Try this by clicking on "👋🏾 Introduction" now and seeing it minimize.



💡 Extra bonus: Use comfortable aliases to run commands
==============

kubectl [bash auto-completion](https://kubernetes.io/docs/tasks/tools/included/optional-kubectl-configs-bash-linux/) has been set up. This means you can run the same command with:

```
k get ns
```

And the shortcuts provided by [zsh plugins](https://github.com/ohmyzsh/ohmyzsh/blob/master/plugins/kubectl/README.md) have also been set up, allowing the same command to be run as:

```
kgns
```

If you are not familiar with these that is OK as all commands will be provided in long form. If you are familiar, you should feel comfortable exploring with these available shortcuts!
