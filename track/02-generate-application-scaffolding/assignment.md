---
slug: generate-application-scaffolding
id: okgzfoly5zg5
type: challenge
title: Generate application scaffolding
teaser: At its core, an operator is an application that runs in Kubernetes. In this
  challenge you will generate scaffolding for this application to get started quickly.
notes:
- type: text
  contents: |-
    Now that you are comfortable in the environment,
    it is time to get started with `kubebuilder`.

    **In this challenge you will:**
    * Initialize Kubebuilder
    * Run the generated operator application locally
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

🚀 Get started
==============

A Kubernetes operator is an application that extends the functionality of the Kubernetes API. An operator automates the resource creation, configuration, and management for another application.

Operators listen to changes of a specified Kubernetes resource rather than HTTP or GRPC requests like more traditional applications.

Today you will create a custom resource definition (CRD) and an operator that takes action when that CRD changes.

🏗 Using the right tools
==============

While an operator and CRD can be generated by hand, there is a tool called `kubebuilder` that can generate scaffolding to get you started quickly.

Your tutorial sandbox computer has [Kubebuilder](https://github.com/kubernetes-sigs/kubebuilder) already installed.

Get started by initializing a Kubebuilder application in your `K8s Shell` tab:

```
kubebuilder init \
  --plugins=go/v4-alpha \
  --repo my.domain
```
This command has generated scaffolding files now visible in the `Code editor` tab. While these are exciting to explore, try to delay this curiosity for now. The rest of this track will jump into key getting started files.

♲ Understanding developer lifecycle tasks
==============

Kubebuilder uses a [Makefile](https://www.gnu.org/software/make/manual/html_node/Introduction.html) as home for all useful commands.

In Make, commands are called "targets". It is common practice to design these targets consistently across local, remote, and Continuous Integration (CI) environments. This enables better debuggability and maintainability.

To see available targets, run in the `K8s Shell`:

```
make help
```

Within this help output, take a look for the descriptions of the four targets you will use most today:
* `install`
* `run`

Then in the bonus challenges you may also touch on:
* `docker-build`
* `deploy`
* `test`

Continue to the next header to use your first Make target.


👩🏾‍💻 Running your Application
==============

Yes, this is only generic scaffolding. But the provided Golang application is usable and even includes basic operability needs.

While you are developing a new application, it is quite time consuming to build and deploy it to a cluster each time. Kubebuilder supports running the application locally which lets you iterate more quickly as you are developing. To run this Golang application locally, go to the `K8s Shell` tab and enter:

```
make run
```

This command may take a few minutes (particularly `go vet` may appear to hang!).

While the command is running, navigate to `main.go` in the root directory (`demo`) of your `Code editor` tab. In this file, look at line 64 to see the `NewManager` function, which is what creates the operator application.

> 💡 If you want to navigate to a specific place in the code editor quickly, type `ctrl+p` (`cmd+p` on macs) and enter the filename. Additionally, you can append a specific line number after a colon (e.g. `main.go:64`).

In the list of options passed to this `NewManager` function (lines 65 to 70), you will see configuration for both a metrics and health probe endpoint. These will become visible in the output of the `make run` command.

Return to the `K8s Shell` tab and view the progress of the run command.

Returning to your `K8s Shell`, you should see a few commands running. This includes prerequisite Make targets like `test` and `vet`. When it is complete, you should see the following four log lines at the end of the output:

```
INFO  controller-runtime.metrics  Metrics server is starting to listen  {"addr": ":8080"}
INFO  setup starting manager
INFO  Starting server {"kind": "health probe", "addr": "[::]:8081"}
INFO  Starting server {"path": "/metrics", "kind": "metrics", "addr": "[::]:8080"}
```
While minimal for now, this is your operator ✨ You will continue extending this application to include any necessary business logic.


💡 Extra bonus: Understand make target prerequisites
==============

Before the server logs you will have seen other output described as prerequisite targets for the `run` target. This section will describe how to understand what the Makefile runs when you write a command.

The `run` target is on `Makefile:68` in the root of your `Code editor`. Here you will see the target defined as:

```
run: manifests generate fmt vet ## Run a controller from your host.
  go run ./main.go
```

In Makefiles, targets are defined as a name followed by a colon (`:`). Any names listed after this target definition are other targets that run as prerequisites.

In this case, there are four prerequisites defined as other targets in this same Makefile. To be more specific, `manifests` and `generate` both run Kubebuilder `controller-gen` commands to generate some Golang code. This code is then formatted and validated by `fmt` and `vet`. Finally, the original `run` target executes the generated and formatted code.


📕 Summary
==============

There are a number of options for getting started with developing controllers and operators for Kubernetes. Kubebuilder is a great choice due to its opinionated support while also providing enough flexibility to create what you need.

You need a way to define and run your core business logic as an operator. Using Kubebuilder, you get started with an opinionated way to build, test and deploy a fit for purpose Golang application.

> 💡 You may have noticed that Kubebuilder always uses the term "controller". Don't let this get too confusing, despite this track focusing on building an operator.
>
> Both controllers and operators are, applications running in Kubernetes that respond to changes in specified resources. Operators are a subset type of controller. An operator specifically manages operational concerns for another application.
>
> For the remainder of this tutorial you can treat the `controller` referenced in Kubebuilder code as synonymous with `operator`.