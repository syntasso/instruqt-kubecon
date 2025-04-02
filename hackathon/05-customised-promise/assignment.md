---
slug: customised-promise
id: vnejlpe3y2xi
type: challenge
title: Customising a platform for the organisation
teaser: Extend community Promises for bespoke needs
notes:
- type: text
  contents: |-
    # Internal platforms need to be...well, internal

    If an organisation can take a platform off the shelf, it should. When an organisation is simple enough and flexible enough to adopt the decisions provided by a 3rd party provider, they save a lot of time and money in implementation.

    But when an organisation needs to incorporate its own special sauce, whether that be for compliance, speciality DevEx, or otherwise, there needs to be a way to make sure these custom processes and tools are incorporated.

    This stage will look at an example of adding a very simple addition to the community App Promise to enable adding environment variables for users.
tabs:
- id: zx9uugtbvqv1
  title: terminal
  type: terminal
  hostname: docker-vm
  workdir: /root/hackathon/app-as-a-service
- id: 2nfdzkh9zpxg
  title: Editor
  type: code
  hostname: docker-vm
  path: /root/hackathon/app-as-a-service
- id: udisf5gw02dw
  title: Gitea
  type: service
  hostname: docker-vm
  path: /gitea_admin/kratix/src/branch/main/platform-cluster/resources
  port: 31443
- id: hjjpprypj3fd
  title: Example App UI
  type: service
  hostname: docker-vm
  path: /
  port: 80
difficulty: basic
timelimit: 1800
enhanced_loading: null
---

The power of an open source software (OSS) community is that existing resources like the PostgreSQL and App Promises are only the beginning. The solutions will always be built for wider consumption or a subtly different use case. That is because no community or vendor can ever be as aware of, or committed to, the exact problem a single company is facing. That makes the OSS community a jumping-off point for further customisation.

💭 Designing the App Promise update
===

To extend an existing Promise, it is just a matter of updating the specification and then re-applying it to the cluster.

In this case, the App Promise requires adding environment variable support, which depends on two changes:
1. Updating the API to accept a list of environment variables
1. Updating the Workflow to pass these environment variables through to the Kubernetes Deployment

> [!NOTE]
> This workshop will not touch on [Promise versioning](https://docs.kratix.io/main/reference/promises/releases) or manage a breaking API change though both of these are supported by the Kratix framework.

📥 Extending the user API
===

To view the current Promise, navigate to the [Editor tab](tab-1) and click on the `promise.yaml` file.

The first change will be to accept a list of environment variables from the end users. Since this field is optional, it will not break existing users and can be added directly to the currently live version of the API, which is found in lines 26-61.

The parameters start on line 31 and are called "properties". Properties are written in the format of an object with the property name as the key and a set of additional details underneath. In the case of environment variables, the property should look like this:

```yaml,nocopy
  env:
    description: The environment variables for the container
    type: object
    additionalProperties:
      type: string
```

The easiest way to get this in the right place in the file is to do it via the [terminal tab](tab-0) with this command:
```bash
yq eval -i '.spec.api.spec.versions[0].schema.openAPIV3Schema.properties.spec.properties.env = {
  "description": "The environment variables for the container",
  "type": "object",
  "additionalProperties": {
  "type": "string"
  }
}' ${HOME}/hackathon/app-as-a-service/promise.yaml
```

Once this command is run in the terminal, return to the [Editor tab](tab-1) and refresh the files using the white circle arrow above the file list. The new property will then be inserted starting on line 55.

To then update the platform, re-apply the Promise to the Kubernetes cluster in the [terminal tab](tab-0):

```bash
kubectl --context $PLATFORM apply -f ${HOME}/hackathon/app-as-a-service/promise.yaml
```

And then use the `explain` command to see the new field:
```bash
kubectl --context $PLATFORM explain app.spec
```

🌈 Use the new requirements
===

With the API being updated to accept this information, a user can update their request to set an environment variable. Do this for the Todoer app using the following command:

```bash
cat << EOF | kubectl apply --context $PLATFORM -f -
apiVersion: marketplace.kratix.io/v1
kind: app
metadata:
  name: todoer
  namespace: default
spec:
  name: todoer
  image: syntasso/sample-todo-app:v1.0.0
  dbDriver: postgresql
  service:
    port: 8080
  env:
    VERSION: 1.12.1
EOF
```

🆕 Using the new API
===

Now the new fields are available to use in the Promise API, we have prepared a new script called `environment-vars-configure` and we need to add it to the pipeline somewhere.

> [!NOTE]
> While these scripts are written in Bash, many users use other languages, such as Golang, Python, Rust, and Ruby when building more complex workflows.
>
> For example, [OpenCredo](https://www.opencredo.com/) engineers created a [community utils package for Rust](https://github.com/opencredo/kratix-utils).


When Kratix starts the workflow, it will mount the following three volumes:

- `/kratix/input`: Kratix will add the user's request into this directory as object.yaml.
- `/kratix/output`: the files in this directory will be scheduled to a matching Destination.
- `/kratix/metadata`: a directory where additional metadata can be attached to the request

Reviewing the the `environment-vars-configure` file it is expecting a kubernetes deployment in `output/deployment.yaml` so it can attach the environment variables a config map to existing output. As we know the `resource-configure` script is responsible for creating the kubernetes manifests, we must place our new script after that executes.

Open the Editor Tab promise yaml and update the Promise workflow so it looks like this:

```yaml,nocopy
workflows:
  resource:
    spec:
       containers:
         - name: create-resources
           image: ghcr.io/syntasso/kratix-marketplace/app-as-a-service-configure-pipeline:v0.1.0
           command: [resource-configure]
         - name: database-configure
           image: ghcr.io/syntasso/kratix-marketplace/app-as-a-service-configure-pipeline:v0.1.0
           command: [database-configure]
         - name: environment-vars-configure
           image: ghcr.io/syntasso/kratix-marketplace/app-as-a-service-configure-pipeline:v0.2.0
           command: [environment-vars-configure]
```

The easiest way to get this in the right place in the file is to do it via the [terminal tab](tab-0) with this command:

```bash
yq eval -i '.spec.workflows.resource.configure[0].spec.containers += [{
  "name": "environment-vars-configure",
  "image": "ghcr.io/syntasso/kratix-marketplace/app-as-a-service-configure-pipeline:v0.2.0",
  "command": ["environment-vars-configure"]
}]' ${HOME}/hackathon/app-as-a-service/promise.yaml
```

> [!NOTE]
> We've prebuilt the `ghcr.io/syntasso/kratix-marketplace/app-as-a-service-configure-pipeline:v0.2.0` image.
>
> Psst, the up-to-date code and scripts needed to build and load any changes are included in the scripts folder for review.

📈 Updating the Promise
===

Now that the has been updated, reapply it to the cluster:

```bash
kubectl --context $PLATFORM apply -f ${HOME}/hackathon/app-as-a-service/promise.yaml
```

It will be clear this is an update as the output will `configure` the Promise rather than `create` it. Once this is applied, Kratix orchestrates the platform to roll out the changes. To watch this, run:

```bash
kubectl --context $PLATFORM get pods -A --watch -l kratix.io/promise-name=app
```

> [!NOTE]
> To exit the watch comment, just use `ctrl+c`

Our example todo app can handle a few environment variables. We have set the version environment variable '1.12.1' to an existing running deployment, and that will get updated as Kratix updates the deployment definition, so the UI is updated with the version number once that change is complete.


> [!NOTE]
> Our todo app also has an enterprise mode which is configurable with the boolean `ENTERPRISE` env var.
>
> Feel free to experiment!

🎁 Wrap up
===

With this section complete, the platform allows users to self-serve high-level resources from a user-friendly interface while also enabling the experts in the organisation to add specific requirements.

But while many application developers love GitOps, many don't. And even those who do would benefit from different types of interactions depending on the job at hand.

The next section looks at how to take this API and expose it as a user-friendly portal interface to hopefully improve adoption and user happiness!
