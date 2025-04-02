---
slug: fleetops
id: sazf39gvdjyo
type: challenge
title: Managing updates with ease
teaser: Using FleetOps to manage and update all resources
notes:
- type: text
  contents: |-
    # Adoption may seem the hardest, but just wait til maintenance!

    When platform teams are getting started it feels like getting adoption is the hardest challenge you can face. But when you achieve adoption, you actually face a much harder challenge...how to manage the resources all those users depend on.

    In this section, you will look at how to update your requirements across all users of your hackathon environment. Gaining confidence that these applications can live on beyond just a single day- or week-long activity.
tabs:
- id: ujxz1yzuw1xz
  title: terminal
  type: terminal
  hostname: docker-vm
- id: 6jwhylzixsqn
  title: Editor
  type: code
  hostname: docker-vm
  path: /root/hackathon
- id: a5mjmho4lyfy
  title: Gitea
  type: service
  hostname: docker-vm
  path: /gitea_admin/kratix/src/branch/main/platform-cluster/resources
  port: 31443
- id: 1rebfsbbe7f0
  title: Backstage
  type: service
  hostname: docker-vm
  path: /
  port: 31340
difficulty: basic
timelimit: 1800
enhanced_loading: null
---

🤹🏽 Managing a successful platform
===

Welcome back, since the last section time has fast forwarded and 10s applications have been deployed via the hackathon (think 100s if it weren't for local Kubernetes clusters 🥴) and lessons were learned.

It turns out the decision to set replicas to 1 for the applications has caused high toil for the service provider as the applications have had lower-than-usual reliability, and users have not understood why.

But that's OK! One of the goals for this hackathon was to get more hands-on with cloud-native technologies. In the process, a lot of lessons have been learned about what it takes to run an application on Kubernetes.

👩🏾‍💻 Designing a fix
===

Based on experience and research, it is now clear that a minimum of 2 replicas is required. The goal for this section is to update each application to set that minimum for all current and future applications.

Unlike code templates that live in different code repositories, these definitions are maintained by the platform. This means the service provider can see the state of all these applications as well as update them without application team involvement.

What might this look like? Well, first, during that fast-forward timeline, there were already added details to the status of each resource for observability over the platform state. Use the following command to view the number of replicas and max unavailable number for each application:

```bash
kubectl --context $PLATFORM get apps -o custom-columns="NAME:.metadata.name,REPLICAS:.status.replicas"
```

With this information, it is clear which applications need to be updated (all!), and it is understood that this is safe to do so.

> [!NOTE]
> If you see `<none>` it may be that the app is not provisioned yet. Re-run the command and see if the replicas appears.

This is another Promise update, this time to set these fields during the workflow. One way to do this would be to update the existing workflow like in the previous section. But to show a different way, this update will add another container to the pipeline which alters the original deployment before scheduling.

🚀 Execute one update across the fleet
===

To do this, run the following command:
```bash
yq eval '.spec.workflows.resource.configure[0].spec.containers += [{
  "image": "ghcr.io/syntasso/kratix-marketplace/app-as-a-service-configure-pipeline:v0.1.0",
  "name": "replica-migration",
  "command": ["/bin/sh","-c"],
  "args": ["set -x
    if [ $(yq \".spec.replicas\" /kratix/output/deployment.yaml) -lt 2 ]; then
      yq eval \".spec.replicas = 2\" /kratix/output/deployment.yaml -i;
      yq eval \".replicas = $(yq \".spec.replicas\" /kratix/output/deployment.yaml)\" -i /kratix/metadata/status.yaml;
    fi
  "]
}]' -i ${HOME}/hackathon/app-as-a-service/promise.yaml
```

This update can be viewed on the `app-as-a-service/promise.yaml` file on line 91 in the [Editor tab](tab-1) and then applied in the cluster on the [terminal tab](tab-0) with the following command:
```bash
kubectl --context $PLATFORM apply -f ${HOME}/hackathon/app-as-a-service/promise.yaml
```

Be quick to run this command to see the change rollout. First, the workflows run on the platform cluster, and then the updated expectations start being realised on the worker clusters:
```bash
pods -w
```

The other option is to see the changes in the replicas reported in the status:
```
kubectl --context $PLATFORM get apps -o custom-columns="NAME:.metadata.name,REPLICAS:.status.replicas" --watch
```

> [!NOTE]
> `pods` is a custom script which will view the pods on both the `platform` and `worker` clusters with a watch command. That means each update to a pod as it gets created and executed will be made visible.


🎉 Congratulations, that is hackathon-ready!
===

With that, this workshop has created a way to provide a community-designed self-service application for a hackathon, customise it to the business requirements, and then maintain the applications created in an efficient way.

More specifically, you have been able to:
* Turn a previous manually-triggered user request into a self-service API
* Rely on community examples of platform components (Promises) to get started quickly
* Compose a higher-level paved path by combining multiple Promises
* Customise and upgrade the platform services to include new (organisation-specific) business rules
* Provide user-friendly interfaces without reimplementing the business rules

Click `next` one last time to access the full environment, including all the available tabs and a diagram of how everything works together.
