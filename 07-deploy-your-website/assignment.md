---
slug: deploy-your-website
id: u5nkkdsxujwa
type: challenge
title: Deploy your website from the controller
teaser: Extend the controller to complete a deployment of your website as customized
  by a Website resource.
notes:
- type: text
  contents: |-
    Log lines allow you to understand when the reconcile loop is called, but now it is time to use your operator to actually operate an application.

    **In this challenge you will:**
    * Create a deployment to run your website whenever the controller reconciles
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
difficulty: basic
timelimit: 600
---

✅ Some new setup has been completed
==============

Since you finished the last challenge, a change has been made to your controller.

Navigate to `controllers/website_controller.go` in your `Code editor` tab and scroll all the way to the bottom. Here you should find a new function called `newDeployment`.

This function encapsulates the necessary Golang code to create a customized deployment for your website.

However, you still need to call this function in the Reconcile loop.

✍🏾 Creating a deployment in the reconcile loop
==============

This `newDeployment` function can be called using the following snippet. You should place this snippet directly below the log line you edited in the last challenge:
```
  // Attempt to create the deployment and return error if it fails
  err = r.Client.Create(ctx, newDeployment(customResource.Name, customResource.Namespace, customResource.Spec.ImageTag))
  if err != nil {
    log.Error(err, fmt.Sprintf(`Failed to create deployment for website "%s"`, customResource.Name))
    return ctrl.Result{}, err
  }
```

🛂 Permissions for the operator
==============

It is all well and good to tell the operator to create a deployment, but is it allowed? In Kubernetes there is strict role based access control (RBAC) that limits what actions people and applications can take.

With this new change, we now need the operator to be allowed to work with deployments. Kubebuilder provides a mechanism to do this very easily through comments much like those used in the CRD fields.

If you look near the top of the controller file you should see some comment lines that start with `//+kubebuilder:rbac`. Each line describes a single RBAC permission.

In order to provide access to work with deployments, you need to add the following permission line:
```
//+kubebuilder:rbac:groups=apps,resources=deployments,verbs=get;list;watch;create;update;patch;delete
```

This is fairly broad permissions since it allows all verbs, but these can be limited these based on very specific needs. Kubebuilder will then translate this into the necessary service accounts when you build the deployment.

🧞 Creating a deployment for your current website
==============

Since you created a Website resource earlier, this should still be in your cluster.

Confirm this by running the following command in the `K8s Shell` tab:
```
kubectl get websites.kubecon.my.domain
```

With this already in your cluster, when you start up your controller again it will reconcile immediately. During reconciliation the controller will try to create a deployment as you have defined.

To see this, go to the `Run Shell` tab and start the controller again with:
```
make run
```

You should see the same log lines as before including the reference to `latest` imageTag.

Once you see this log go back to the `K8s Shell` tab and check for deployments with:
```
kubectl get deployments
```

You should now see a single deployment with 2 replicas starting.

> 💡 To see more details about this deployment, run `kubectl describe deployment` and look for configurations that your code sets like number of `Replicas` and `Labels`.

🧨 But what happens on update?
==============

While creating a deployment is an exciting and real world use case for your controller, what happens if it is updated?

Test this by just stopping and restarting your controller. To stop you controller go to the `Run Shell` tab and use `ctrl+c`. Then restart with the same `make run` command you used before.

You will see the log line but then an error trace something like:

```
ERROR   Failed to create deployment     {"controller": "website", ... "error": "deployments.apps \"website-sample\" already exists"}
sigs.k8s.io/controller-runtime/pkg/internal/controller.(*Controller).Reconcile
        /root/go/pkg/mod/sigs.k8s.io/controller-runtime@v0.12.2/pkg/internal/controller/controller.go:121
sigs.k8s.io/controller-runtime/pkg/internal/controller.(*Controller).reconcileHandler
        /root/go/pkg/mod/sigs.k8s.io/controller-runtime@v0.12.2/pkg/internal/controller/controller.go:320
sigs.k8s.io/controller-runtime/pkg/internal/controller.(*Controller).processNextWorkItem
        /root/go/pkg/mod/sigs.k8s.io/controller-runtime@v0.12.2/pkg/internal/controller/controller.go:273
sigs.k8s.io/controller-runtime/pkg/internal/controller.(*Controller).Start.func2.2
        /root/go/pkg/mod/sigs.k8s.io/controller-runtime@v0.12.2/pkg/internal/controller/controller.go:234
```

That is because the code asks to create a deployment, but there already is one in the cluster. Continue on to see how to deal with this issue.


📕 Summary
==============

In this challenge you added a more realistic use case for your controller by asking it to deploy a website for you.

But this quickly resulted in more work to be done to handle when a deployment already exists. Don't worry, that is coming up next!
