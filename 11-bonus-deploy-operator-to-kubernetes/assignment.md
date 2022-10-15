---
slug: bonus-deploy-operator-to-kubernetes
id: kx3btbmriphs
type: challenge
title: 'Bonus: Deploy operator to Kubernetes'
teaser: It is time to stop running locally, and start deploying to Kubernetes
notes:
- type: text
  contents: |-
    Now that you have a complete operator, it is time to deploy it to Kubernetes!

    While `make run` gives a fast feedback look for development, eventually you will need to deploy your operator to a cluster.

    **In this challenge you will:**
    * Build a docker image for your operator
    * Load the docker image into your cluster
    * Generate an operator distribution
    * Deploy the operator distribution into your cluster
tabs:
- title: K8s Shell
  type: terminal
  hostname: kubernetes-vm
  workdir: /root/demo
- title: Run Shell
  type: terminal
  hostname: kubernetes-vm
  workdir: /root/demo
- title: Code editor
  type: service
  hostname: kubernetes-vm
  path: /
  port: 8443
- title: Website
  type: service
  hostname: kubernetes-vm
  path: /
  port: 31000
difficulty: basic
timelimit: 1
---

🎁 Creating your operator release
==============

Your operator is just an application, so it needs to be packaged as a OCI compliant container image just like any other container you want to deploy.

Kubebuilder knows this and provides the Make command you need. If you run the following command, you will end up with a local docker image. By default it is named based on the `IMG` tag found at the top of the Makefile:
```
make docker-build
```

> ⏳ Note that this may take a few minutes!

This docker image is currently only usable on your local computer. Typically you would tag and push this image to a repository in the cloud so that your Kubernetes cluster could pull it down from the internet. Today you will not be doing this.

⬆️ Uploading your image locally
==============

Instead, today you will load this local image into your local `k3s` Kubernetes cluster in order to keep everything local. To load this image, you first need to create an output of the image:
```
docker save --output /root/demo/controller-latest.tar controller:latest
```

Then import this to the cluster using:
```
k3s ctr images import /root/demo/controller-latest.tar
```

🛫 Deploying to Kubernetes
==============

Now that you have your application packaged and available to your cluster, you are ready to actually run the operator. This operator relies on simple deployment configuration which is generated using `make manifests` and stored in `config` > `manager`.

The following make command generates the manifests and applies them to the cluster:
```
make deploy
```

Once applied, view the running operator using:
```
kubectl --namespace demo-system get deployments
```

If it is not healthy when you first check, you can use the `--watch` flag on your previous command, or just try again. It should take no more than about 15 seconds to start healthy.

🛝 Using the operator in Kubernetes
==============

With this operator deployed to Kubernetes you can now use it in the same way as when it was deployed locally.

For example, create a new Website resource, or patch the existing one. The big difference is that to see te logs you need to use the following Kubernetes command:

```
kubectl --namespace demo-system logs deploy/demo-controller-manager
```


📕 Summary
==============

Writing any code requires a lot of iteration and faster feedback is helpful. That is why you have been working with a local run command for the operator up until this point. This experience shows how the process of deploying to Kubernetes adds a lot of time just from the process of building the docker image.

That being said, the operator will need to run in Kubernetes in the long run and using the `deploy` make command will allow you you to deploy and test your operator in a more realistic fashion. For example, had you not added the permissions to work with deployments and services, your operator would still have worked when running locally since it is using your personal permissions. However, once deployed to Kubernetes the operator is reliant on only its own permissions and would have failed without the additional RBAC provided.

🧞‍♀️ Some magic with local clusters
==============

Since this is a quick tutorial, there is one small thing that was done for you.

In this tutorial you were using a cluster created with [k3s](https://k3s.io/) and in this specific challenge you needed to make a local docker image available. In order for this to work, you need an `imagePullPolicy` set that will set a preference to the local image.

[By default](https://kubernetes.io/docs/concepts/containers/images/#imagepullpolicy-defaulting), when the image tag is set to `latest` the pull policy will be `Always` which means it will not use any locally cached images. To overcome this, there was a patch applied that set the pull policy. This patch can be found in the `Code editor` tab under `config/manager/kustomization.yaml:12`.


Other local cluster creation tools like [KinD](https://kind.sigs.k8s.io/) do similar things so check the docs. And for more details, please see a [fantastic write up](https://iximiuz.com/en/posts/kubernetes-kind-load-docker-image/) by [Ivan Velichko](https://twitter.com/iximiuz).
