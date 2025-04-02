> [!CAUTION]
> This course was first presented at KubeCon NA in Detroit (2022)
> The version of golang and other tools is dated to that time and may not be working as designed.
> For now, this is best used as a reference rather than as an operational course.

# Create Your First Kubernetes Operator

This is the supporting repository for the KubeCon North America 2022 tutorial by the same name.

Some additional information can be found on the tutorial website.

> [!CAUTION]
> 
> **This repository is provided as is with no guarantees or support.**
> 
> **It is advised not to run any of the scripts in this repository on your computer without deep personal review.**

## Creating your own Instruqt track

This is all the code required to create and run your own [Instruqt](https://instruqt.com/) track.

You will need to create new track ID but all of this content should be reusable should you sign up for and create content with Instruqt.

## Using this outside of Instruqt

This is the code necessary to build a track in [Instruqt](https://instruqt.com/). Therefore, you will need to navigate some configuration to use the tutorial outside of an Instruqt provided environment.

The tutorial is stored in the [track](./track/) folder. Each step is in order with it's number prepended to the directory name. These are called "challenges".

Inside of each challenge directory you will see an `assignment.md`. This file contains some configuration at the top in YAML format and then the tutorial instructions at the bottom in Markdown. You can follow this markdown instruction from any computer that meets the prerequisites.

If you see a `setup-kubernetes-vm` file in the directory, you should review the bash commands in this file before starting the assignment. Running these bash scripts is at your own risk. They were built to run on a sandbox VM. It is advised that you view the intention and recreate as necessary.

### Prerequisites

This tutorial was originally built to be run on a server by Instruqt. To run this on your own machine you will need:

1. Access to a Kubernetes cluster. If you do not have one, I suggest either [KinD](https://kind.sigs.k8s.io/docs/user/quick-start/) or [k3s](https://docs.k3s.io/quick-start) to get started quickly.
1. A working directory called `demo`
1. [Golang version 1.18](https://go.dev/dl/)
1. [Kubebuilder](https://book.kubebuilder.io/quick-start.html#installation)

For further nice to have items, please review the [server setup file](./track/track_scripts/setup-kubernetes-vm).

### Provided Solutions

Each of the challenges build on each other, but you can also skip ahead by copying the code from the [support](./support/) directory. Each chapter directory holds a version of the demo working directory as it should be at the end of the chapter.
