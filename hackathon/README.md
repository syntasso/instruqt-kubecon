> [!NOTE]
> This course was first presented at KubeCon EU in London (2025)

# Create Your Own Hackathon in a Box

This is the supporting repository for the KubeCon Europe 2025 tutorial: https://kccnceu2025.sched.com/event/1a05dda15990c9198745b665f56bde77.


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
