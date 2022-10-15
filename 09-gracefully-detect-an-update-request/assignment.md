---
slug: gracefully-detect-an-update-request
id: 53brpzghvx0e
type: challenge
title: Gracefully detect an update request
teaser: While creating is necessary, most of the time you will be updating an existing
  website. Learn how to detect and execute an update when needed.
notes:
- type: text
  contents: |-
    Deploying your website for the first time is very exciting! After an initial launch, the excitement comes when you release new features and improvements.

    While you have launched your website,  you are now blocked. You get an error any time you update your website since the operator can not re-create a deployment using the initial command.

    **In this challenge you will:**
    * Detect an update scenario by catching a specific error
    * Understand more about what logic needs to live in this error catch
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

🙉 Why is the operator so noisy
==============

Right now, your operator will try to create two new resources each time it reconciles, a deployment and a service. But this is not always necessary!

The reconcile loop runs under a few scenarios:
1. On operator start / restart
1. Periodically (by default this is daily)
1. Each time a Website resource event happens

If the deployment and service already exist, the current code will error when any of these scenarios occur.

To see this happen, imitate the first scenario by restarting your operator in the `Run Shell` tab with:

```
make run
```

To stop this noisy error loop, stop the operator running with `ctrl+c`.

🧑🏽‍🎓 Learning the update error
==============

There is a lot to unpack to handle update scenarios in a robust fashion. A natural starting point is to capture the fact that these resources already exist as a known failure. Then you can at least choose to ignore this failure rather than doing what happens now where you throw noisy errors that get logged.

The errors in the `Run Shell` tab should look similar to:
```
ERROR   Reconciler error        {"controller": "website", ... "error": "Website.kubecon.my.domain \"website-sample\" already exists"}
sigs.k8s.io/controller-runtime/...
        /root/go/pkg/mod/sigs.k8s.io/...
sigs.k8s.io/controller-runtime/pkg/...
        /root/go/pkg/mod/sigs.k8s.io/...
```

> 💡 This error may be repeated many times as the reconcile loop will continue to try and reconcile after failures. To stop this use `ctrl+c` to cancel the run.

You can see the `error` is `"Website.kubecon.my.domain \"website-sample\" already exists"`. Now you now know that the error type `already exists` indicates that the create method is failing due to a pre-existing resource.

🤫 Not erroring on update
==============

To handle the `already exists` error you need to add a conditional inside of where you catch the create error. In `Code editor` tab navigate to `website_controller.go` and look for the existing `newDeployment` function call (around line 77). It should look like this:

```
  err = r.Client.Create(ctx, newDeployment(customResource.Name, customResource.Namespace, customResource.Spec.ImageTag))
  if err != nil {
    log.Error(err, fmt.Sprintf(`Failed to create deployment for website "%s"`, customResource.Name))
    return ctrl.Result{}, err
  }
```

Now replace that entire snippet with this more detailed handler:
```
  err = r.Client.Create(ctx, newDeployment(customResource.Name, customResource.Namespace, customResource.Spec.ImageTag))
  if err != nil {
    if errors.IsAlreadyExists(err) {
      log.Info(fmt.Sprintf(`Deployment for website "%s" already exists"`, customResource.Name))
      // TODO: handle updates gracefully
      return ctrl.Result{}, nil
    } else {
      log.Error(err, fmt.Sprintf(`Failed to create deployment for website "%s"`, customResource.Name))
      return ctrl.Result{}, err
    }
  }
```

Follow the pattern to make the same change for creating a new service.

Find the previously added `newService` code snippet that looks like this:

```
// Attempt to create the service and return error if it fails
err = r.Client.Create(ctx, newService(customResource.Name, customResource.Namespace))
if err != nil {
  log.Error(err, fmt.Sprintf(`Failed to create service for website "%s"`, customResource.Name))
  return ctrl.Result{}, err
}
```

Replace that full snippit catch with this more detailed handler:
```
err = r.Client.Create(ctx, newService(customResource.Name, customResource.Namespace))
if err != nil {
  if errors.IsAlreadyExists(err) {
    log.Info(fmt.Sprintf(`Service for website "%s" already exists`, customResource.Name))
    // TODO: handle updates gracefully
    return ctrl.Result{}, nil
  } else {
    log.Error(err, fmt.Sprintf(`Failed to create service for website "%s"`, customResource.Name))
    return ctrl.Result{}, err
  }
}
```

**💾 Once these changes are complete. Remember to save the file which with `ctrl+s`.**

😌 Running your operator in peace
==============

Once these two changes are in place, stop your operator using `ctrl+c` in the `Run Shell` tab. Then restart your operator in the same tab using `make run`.

You should no longer see any error tracing, only the error log for visibility.


📕 Summary
==============

Now you have implemented a very simple way to track when a resource already exists! 💪🏿

Different updates may require different actions. For example, adding a label may be simple, but changing image tags may require more caution.

This tutorial will not delve into these nuances due to strict time constraints. But with these basics should have all the tools to tackle these business cases as you reach them!
