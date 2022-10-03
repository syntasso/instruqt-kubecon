---
slug: get-to-know-the-platform
id: yzq8tbn8srib
type: challenge
title: Get to know the platform
teaser: Explore how this course is being delivered in the browser, but has all the
  power of a local Kubernetes developer's laptop.
notes:
- type: text
  contents: |-
    This track uses a single node Kubernetes cluster on a sandbox virtual machine (VM).

    Please wait while we boot the VM for you and start Kubernetes. Once the VM
    is ready you will see a green start button in the bottom right hand corner.

    There are a number of slides with corresponding hands on activities, these are each called "challenges"

    **In this first challenge, you will:**
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
timelimit: 300
---

👋🏾 Introduction
==============

Welcome to your personal Kubernetes cluster! 🏡

There are two tabs on the top left. One named `K8s Shell` tab and the other `Code editor`.

Throughout this course you will use `K8s Shell` to interact with your Kubernetes (K8s) cluster.

To see how this works, try running the following command:

```
kubectl get namespaces
```

> 💡 You can copy this command by clicking anywhere in the text box and then paste it into the terminal

And in the `Code editor` tab create and edit files in a [Visual Studio Code](https://code.visualstudio.com/) style environment.

To see how this works, click on the `Code editor` tab and navigate to the file `.example-namespace.yaml`

Then edit that file to configure a new namespace in Kubernetes by pasting the following code into the file:

```
---
apiVersion: v1
kind: Namespace
metadata:
  name: example
```

Now the real power is in your ability to create files in the code editor and then run those files in the shell. Return to the `K8s Shell` tab and apply this edited file to your cluster using the following command:

```
kubectl apply \
  --filename .example-namespace.yaml
```

Confirm your namespace has been created by running the first get namespaces command again and seeing a much newer namespace called `example` at the bottom of the list:
```
kubectl get namespaces
```

📕 Summary
==============

Congratulations! You have know navigated your way around the platform and are ready to create your first operator.

To continue to the next challenge, use the green `Check` button at the bottom right of the screen to validate your current work and prepare the next challenge.

> 💡 One last tip: When you are done with a header section, click on the header to minimize and make more space for the next header section. Try this by clicking on "👋🏾 Introduction" now and seeing it minimize.



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
