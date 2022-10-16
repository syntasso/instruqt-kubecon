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

    This tutorial track contains a set of challenges. Each challenge begins with a slide like this. After you click "Start" you will get a set of instructions and any necessary tools.

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
timelimit: 7189
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

You will use the `Code editor` tab to create and edit files in a [Visual Studio Code](https://code.visualstudio.com/) style environment.

To see how this works, click on the `Code editor` tab and navigate to the file `.example-namespace.yaml`

Define a new namespace in Kubernetes by pasting the following code into the file:

```
---
apiVersion: v1
kind: Namespace
metadata:
  name: example
```

When you edit the file, you will see the top of the tab look like a white dot. This indicates a change is not yet saved. Press `ctrl+s` (or `⌘ + s` on a mac) to save the file.

> 💡 Golang files will be formatted on save, so as you continue with pasting code snippets, saving will help make sure your files are always formatted correctly!

Now the real power is in your ability to create files in the code editor and then run those files in the shell. Return to the `K8s Shell` tab and apply this edited file to your cluster using the following command:

```
kubectl apply \
  --filename .example-namespace.yaml
```

Confirm your new namespace by running the first get namespaces command again. You should see a much newer namespace (based on the `AGE` column) called `example` at the bottom of the list:
```
kubectl get namespaces
```

📕 Summary
==============

Congratulations! You have now navigated your way around the platform and are ready to create your first operator.

To continue to the next challenge, use the green `Check` button in the bottom right corner of the screen. This validates your current work and loads the next challenge.

> 💡 Making space: After you complete a header section in these instructions, you can minimize the section by clicking on the header. This makes more space for the next header section. Try this by clicking on "👋🏾 Introduction" now and seeing it fold closed. You can also resize the sidebar with instructions and even close it if you need more working space!



💡 Extra bonus: Use comfortable aliases to run commands
==============

kubectl [bash auto-completion](https://kubernetes.io/docs/tasks/tools/included/optional-kubectl-configs-bash-linux/) has been set up. This means you can run the same command with:

```
k get ns
```

And the shortcuts provided by [zsh plugins](https://github.com/ohmyzsh/ohmyzsh/blob/master/plugins/kubectl/README.md) have also been set up, allowing the same command to also shorten to:

```
kgns
```

If you are not familiar with these that is OK as all tutorial commands are provided in long form. If you are familiar, you should feel comfortable exploring with these available shortcuts!
