---
slug: request-postgres
id: kxs7zswfvwud
type: challenge
title: Requesting PostgreSQL from the platform
teaser: Experience requesting a self-service database
notes:
- type: text
  contents: |-
    # Basic self-service

    Platforms that depend on human intervention either for creation or for access to resources can reduce an organisation's speed to market. With the Postgres Promise installed, it is time to see how users can experience on-demand databases.

    _Keep in mind, this is a very basic user experience and it will be iterated to improve both the platform services available and the user experience by the end of the workshop!_
tabs:
- id: skzot0l3cnxj
  title: terminal
  type: terminal
  hostname: docker-vm
- id: c7l4dzss4zcj
  title: Gitea
  type: service
  hostname: docker-vm
  path: /gitea_admin/kratix/src/branch/main/worker-cluster/resources
  port: 31443
difficulty: basic
timelimit: 1800
enhanced_loading: null
---

🙋🏽 Request a Postgres Instance
===

Many app developers are asked to interface with either GitOps repositories or the `kubectl` CLI and that is where this platform begins as well. _(But don't worry, this can be better and it will improve by the end of the workshop! 💅)_

The first step as a user is is to see what is available on the platform. All platform services are listed as Promises in the Kubernetes cluster:
```bash
kubectl get promises
```

The Promises are available via APIs as described in the third and fourth columns. For example, postgres is available under the `postgresql.marketplace.kratix.io` API.

Below is a short yaml file that is a request to the postgres API. It specifies the platform apiVersion and kind in the first two lines as well as a `spec` field that holds unique requirements for this specific instance. Apply this to the cluster using the terminal.

```bash
cat << EOF | kubectl apply --context $PLATFORM -f -
apiVersion: marketplace.kratix.io/v1alpha2
kind: postgresql
metadata:
  name: example
  namespace: default
spec:
  env: dev
  teamId: acid
  dbName: bestdb
EOF
```
> [!NOTE]
> This request can be made with a git commit and deployed via GitOps. It is recommended to use GitOps in more permanent environments to provide long term traceability and durability.

Once applied, see that flux has pulled this request into the cluster and that request has turned into a resource:
```bash
kubectl --context $PLATFORM get postgresqls
```

> [!NOTE]
> The status of this resource changes in its lifecycle. If the resource is "pending", try again until the version and size of the database created is visible which indicates the request is complete.

Just as there was a Promise workflow on Promise creation, there is a resource workflow triggered by this creation. The resource workflow will generate the declarative code for a database instance based on the configuration set in the request plus platform-defined rules set in the Promise.

View the workflow with the following command:

```bash
kubectl --context $PLATFORM get pods --selector kratix.io/promise-name=postgresql
```

And view the resulting database server starting on the worker cluster with the following command:

```bash
kubectl --context $WORKER get pods --watch
```

Be aware, the above command uses the `--watch` flag as it can take a few seconds for the instance to begin running. Eventually, the output will look like this:
```bash,nocopy
NAME                                READY   STATUS    RESTARTS   AGE
acid-example-postgresql-0           1/1     Running   0          81s
postgres-operator-68c4d858b-kf6pn   1/1     Running   0          5m27s
```

To run additional commands, use ctrl+c (or cmd+c on a mac) to exit from the `watch` command.

And yes, these, too, are scheduled to a git repository by Kratix!

To view them, navigate back to [Gitea](tab-1), where the `worker-cluster/resources` directory is loaded up. The `default/postgresql/example/instance-configure/5058f` directory should appear and, if not, use the refresh button to update the page. Once visible, this directory contains the `postgres-instance.yaml` resources that need to run on the worker cluster.

Also notice that there are some more fields filled in than the set in the request. This is because the platform team has the ability to set certain defaults, in this case, taking `env: dev` and translating that into an instance that is only 1GB and has no backups. This is all configurable by changing the behaviour of the Promise Workflow.

🎁 Wrap up
===

Platforms are only useful when they are used. And users all demand different interaction models: some want browsers, others CLIs, and still others IDE plugins or more. This section shows the API interaction with a platform service which is the groundwork to provide any other requested interface.

Before looking at an example interface on top of the API, it is important to have an API worth interacting with. The next section will extend from a single database to a complete application for users to deliver during the hackathon.
