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
    Deploying your website for the first time is very exciting! After the initial launch, the excitement comes when you release new features and improvmenents to what you've already built. Right now you launched your website, and now you're blocked. You get an error any time your operator reconciles after creation since it can not re-create using the same command.

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

Right now, your controller assumes that each time it reconciles, it needs to create two new resources, a deployment and a service. But that is not true!

The reconcile loop runs periodically, on application start and on resource change among other scenarios. In all of these scenarios when the operator tries to create a new deployment and service it will error.

To see this happen, restart your operator in the `Run Shell` tab with:

```
make run
```

To stop this error loop, just stop the controller running with `ctrl+c`.

🤫 Not erroring on update
==============

There is a lot to unpack to handle update scenarios in a robust fashion. A natural starting point is to capture the fact that these resources already exist as a known failure rather than doing what happens now where you throw noisy errors that get logged.

You need to add a conditional inside of where you catch the create error. In `Code editor` tab navigate to `website_controller.go` and look for the following code snippet that you previously added (around line 77):

```
  err = r.Client.Create(ctx, newDeployment(customResource.Name, customResource.Namespace, customResource.Spec.ImageTag))
  if err != nil {
    log.Error(err, fmt.Sprintf(`Failed to create deployment for website "%s"`, customResource.Name))
    return ctrl.Result{}, err
  }
```

Replace that error catch with this more detailed handler:
```
  err = r.Client.Create(ctx, newDeployment(customResource.Name, customResource.Namespace, customResource.Spec.ImageTag))
  if err != nil {
    if errors.IsAlreadyExists(err) {
      // TODO: handle updates gracefully
      log.Info(fmt.Sprintf(`Deployment for website "%s" already exists"`, customResource.Name))
      return ctrl.Result{}, nil
    } else {
      log.Error(err, fmt.Sprintf(`Failed to create deployment for website "%s"`, customResource.Name))
      return ctrl.Result{}, err
    }
  }
```

Follow the pattern to make the same change for creating a new service. 

Find the code snippet you added previously:

```
// Attempt to create the service and return error if it fails
err = r.Client.Create(ctx, newService(customResource.Name, customResource.Namespace))
if err != nil {
  log.Error(err, fmt.Sprintf(`Failed to create service for website "%s"`, customResource.Name))
  return ctrl.Result{}, err
}
```

Replace that error catch with this more detailed handler:
```
err = r.Client.Create(ctx, newService(customResource.Name, customResource.Namespace))
if err != nil {
  if errors.IsAlreadyExists(err) {
    // TODO: handle updates gracefully
    log.Info(fmt.Sprintf(`Service for website "%s" already exists`, customResource.Name))
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

Once these two changes are in place, try stopping your controller using `ctrl+c` in the `Run Shell` tab and then restarting your operator in the same tab using `make run`.

You should no longer see any error tracing, only the error log for visibility.


📕 Summary
==============

You've implemented a very simple way to track when a resource already exists. Different updates may require different actions. For example, adding a label may be simple, but changing image tags may require more caution.

This tutorial will not delve into these nuances due to strict time constraints, but you should have all the tools to tackle these business cases as you reach them!
