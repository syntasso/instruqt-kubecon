---
slug: introduce-and-view-operator-specific-logs
id: z2x6mgvsq5om
type: challenge
title: Understand the new operator by adding logs
teaser: Explore the Kubebuilder created operator by adding logs and viewing them.
notes:
- type: text
  contents: |-
    You explored the generated CRD, and added this custom `Website` type to your cluster.

    Now it is time to understand the generated operator. You will get to see your application respond to a request for a Website custom resource.

    **In this challenge you will:**
    * Add logs in your operator application
    * Run the application locally
    * Request a Website custom resource and view the corresponding  logs
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
timelimit: 1
---

🕵️ Understanding your new operator
==============

When you selected to create a operator along with the Resource, Kubebuilder took care of some key setup:

1. Starts the operator process during application boot
1. Implements a custom `Reconcile` function to run on each resource event
1. Configures the operator to know which resource events to listen to

To see the start process, navigate to `main.go:92` in the root of your `Code editor`. You will see a section that starts the website operator:

```
if err = (&controllers.WebsiteReconciler{
  Client: mgr.GetClient(),
  Scheme: mgr.GetScheme(),
}).SetupWithManager(mgr); err != nil {
  setupLog.Error(err, "unable to create controller", "controller", "Website")
  os.Exit(1)
}
```

This is a call to the function `SetupWithManager(mgr)`  defined in the file `controllers/website_controller.go`.

Navigate to `controllers/website_controller.go:58` to view this function. It is already configured to know about the CRD `kubeconv1beta1.Website` that you explored in the last challenge. This is an example of why defining the custom resource in Golang is so helpful.

Finally, look a bit further up in that same `website_controller.go` file to see the `func (r *WebsiteReconciler) Reconcile` function. This is nearly empty and is where you will add the core of your business logic.

You can run the operator as is since this is an error free implementation. But, you wouldn't be able to tell if it worked since there are no side effects for running the `Reconcile` function, not even any logs!

🪵 Logging from the operator
==============

To make it more obvious when the `Reconcile` function runs, add a simple log line.

To do this, replace the contents of the current function (lines 50 to 54) with the below text:

```
  // _ indicates an unused variable in Golang.
  // By naming the variable, you can use the pre-configured logging framework.
  log := log.FromContext(ctx)

  // Start by declaring the custom resource to be type "Website"
  customResource := &kubeconv1beta1.Website{}

  // Then retrieve from the cluster the resource that triggered this reconciliation.
  // Store these contents into an object used throughout reconciliation.
  err := r.Client.Get(context.Background(), req.NamespacedName, customResource)
  // If the resource does not match a "Website" resource type, return failure.
  if err != nil {
    return ctrl.Result{}, err
  }

  log.Info(`Hello from your new website reconciler!`)

  return ctrl.Result{}, nil
```

**💾 Once this change is complete. Remember to save the file with `ctrl+s` (or `⌘ + s` on a mac).**

What this code snipped does is:

1. Assign the logger to a variable
1. Tests the ability to read the Website CRD, erroring if it is invalid
1. If the CRD is valid, writes a log line
1. Continues on to return healthy at the end of the reconcile loop


🏃🏿‍♀️ Running your application locally
==============

You may have noticed a third tab on this challenge called `Run Shell`, you will use this for a long-running process. This shell is another session on the same machine, so the only difference between it and the `K8s Shell` tab is the title!

In the `Run Shell` tab, start up your updated application with:

```
make run
```

> 💡 Remember, this may take a few minutes

When it completes you should see the same output you saw in the last challenge including both a metrics and health probe endpoint starting.

But you should also see new log lines showing the starting of the website operator as well:

```
INFO    Starting EventSource    {"controller": "website", "controllerGroup": "kubecon.my.domain", "controllerKind": "Website", "source": "kind source: *v1beta1.Website"}
INFO    Starting Controller     {"controller": "website", "controllerGroup": "kubecon.my.domain", "controllerKind": "Website"}
INFO    Starting workers        {"controller": "website", "controllerGroup": "kubecon.my.domain", "controllerKind": "Website", "worker count": 1}
```

This is the starting of the operator process. You have not yet seen the log line since `Reconcile` will only run and print the log line when a `Website` Resource event occurs.

👀 Request a new Website
==============

In the `K8s Shell` tab, request a Custom Resource of type `Website` using the Kubebuilder generated sample file. To see this file, look in the `Code editor` tab under `./config/samples/kubecon_v1beta1_website.yaml`.

Apply the sample file to the Kubernetes cluster with:

```
kubectl apply \
  --filename ./config/samples/kubecon_v1beta1_website.yaml
```

Once applied, return to the `Run Shell` tab and have a look for your log output:

```
INFO    Hello from your new website reconciler! ...
```

Any time you interact with your Website resources a new event triggers. And each event will print the log line from your application.

> 💡You are welcome to play with the resource now. But in order to progress, have one (and only one) Website resource in your cluster before pressing the `Check` button. This will set you up for success on future challenges.

📕 Summary
==============

Congratulations, you have triggered a Website reconciliation by requesting a Website resource!

Next up, you will look at how to change the CRD fields and use these custom fields in your operator reconciliation.
