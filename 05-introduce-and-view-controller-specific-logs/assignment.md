---
slug: introduce-and-view-controller-specific-logs
id: z2x6mgvsq5om
type: challenge
title: Introduce and view controller specific logs
teaser: Explore the Kubebuilder created controller by adding logs and viewing them
  when running locally
notes:
- type: text
  contents: |-
    You have now explored how the CRD was generated and have a cluster that knows about your Website custom resources kind.

    Now it is time to understand the generated controller and view your application respond to a request for a Website custom resource.

    In this section you will:
    * Add logs in your controller application
    * Run the application locally
    * Request a Website custom resource and view the corresponding logs
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

🕵️ Understanding how the controller is created
==============

When you selected to create an controller along with the Resource, Kubebuilder took care of some key setup:

1. Start the controller process during application boot
1. Implement a custom `Reconcile` function run on each resource event
1. Configure the controller to know which resource events to listen to

To see the start process, navigate to `main.go:92` in the root of your `Code editor`. You will see a section that starts the website controller:

```
if err = (&controllers.WebsiteReconciler{
  Client: mgr.GetClient(),
  Scheme: mgr.GetScheme(),
}).SetupWithManager(mgr); err != nil {
  setupLog.Error(err, "unable to create controller", "controller", "Website")
  os.Exit(1)
}
```

This is a call to the function `SetupWithManager(mgr)` which is defined in the file `controllers/website_controller.go:58`.

When you find this function you will see that a new instance of the controller is returned aready configured with what resource to listen for. This is an example of why defining the custom resource in Golang is so helpful. The `kubeconv1beta1.Website` is the Golang resource type which you explored in the last section.

Finally, you can look a bit further up in that same `website_controller.go` file to see how the `Reconcile` function has been generated. This is left nearly empty as this is where the core of your business logic will be added.

While this is an error free implementation, you wouldn't really be able to tell if it worked since there is are no side effects `Reconcile` function, not even any logs!

🪵 Logging from the controller
==============

In order to make it more obvious when the `Reconcile` function is called, you can add a simple log line.

To do this, replace the contents of the current function with the below text:

```
  // _ indicates an unused variable in Golang.
  // By naming the variable, you can use the pre-configured logging framework.
  log := log.FromContext(ctx)

  // Start by declaring the custom resource the type "Website"
  customResource := &kubeconv1beta1.Website{}

  // Then retrieve from the cluster the resource that triggered this reconciliation.
  // This should be then stored into the customResource "Website" object.
  if err := r.Client.Get(context.Background(), req.NamespacedName, customResource); err != nil {
    // If the resource cannot be translated into a "Website" resource type, return failure.
    return ctrl.Result{}, err
  }

  log.Info("Hello from your new website reconciler!")
  log.Info("got resource " + customResource.Name)

  return ctrl.Result{}, nil
```

What this code snipped does is:

1. Assign the logger to a variable you can use
1. Tests the ability to read the Website CRD, erroring if it is invalid
1. If the CRD is valid, writes a log line
1. Continues on to return healthy at the end of the reconcile loop


🏃🏿‍♀️ Running your application locally
==============

You may have noticed a third tab on this section called `Run Shell`. This has been introduced to allow a long running process in one Shell while ongoing commands in the other.

In the `Run Shell` tab, start up your newly updated application with:

```
make run
```

Remember, this may take a few minutes.

When it completes you should see the same output you saw in the last section which shows the starting of both a metrics and health probe endpoint.

But you should also see new log lines showing the starting of the website controller as well:

```
INFO    Starting EventSource    {"controller": "website", "controllerGroup": "kubecon.my.domain", "controllerKind": "Website", "source": "kind source: *v1beta1.Website"}
INFO    Starting Controller     {"controller": "website", "controllerGroup": "kubecon.my.domain", "controllerKind": "Website"}
INFO    Starting workers        {"controller": "website", "controllerGroup": "kubecon.my.domain", "controllerKind": "Website", "worker count": 1}
```

This is the starting of the controller process, but `Reconcile` will only run and print your log line when a `Website` Resource is created.

👀 Request a website
==============

In the `K8s Shell` tab request a Custom Resource of type `Website`. It is easiest to use the generated sample file that you can review in the `Code editor` tab in `./config/samples`.

To use this file, apply it to the Kubernetes cluster with:

```
kubectl apply \
  --filename ./config/samples
```

Once this is applied, you can return to the `Run Shell` tab and have a look for your log output:

```
INFO    Hello from your new website reconciler! ...
```

You can add, update, or delete these Website resources and each time those events occur, you will see another printing of the log line from your application.

In order to progress, have one (and only one) Website resource in your cluster before pressing the `Check` button. This will set you up for success on future sections.

📕 Summary
==============

Congratulations, you have officially triggered a Website reconciliation by requesting a Website resource!

Next up, you will change look at how to change the CRD fields and use these custom fields in your controller reconciliation.
