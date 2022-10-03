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
    While deploying your website for the first time is exciting, dealing with maintenance or feature improvements is far more common. But right now you get an error any time your operator reconciles after creation since it can not re-create using the same command.

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
timelimit: 480
---

🙉 Why is the operator so noisy
==============

Right now, your controller assumes that each time it reconciles, it needs to create two new resources, a deployment and a service. But that is not true!

The reconcile loop runs periodically, on application start and on resource change among other scenarios. In all of these scenarios when the operator tries to create a new deployment and service it will error.

To see this happen, restart your operator in the `Run Shell` tab with:

```
make run
```

🤫 Not erroring on update
==============

While there is a lot to unpack to handle these scenarios in a robust fashion, you can at least capture the fact that these resources already exist as a known failure rather than the rather noisy errors that currently get printed.

To do this, you need to add a conditional inside of where you catch the create error.

For example, in the deployment create method, you already catch the error around line 68:

```
  err := r.createDeployment(ctx, customResource)
  if err != nil {
    log.Error(err, fmt.Sprintf(`Failed to create deployment for website "%s"`, customResource.Name))
    return ctrl.Result{}, err
  }
```

Now all you need to do is replace that error catch with this more detailed handler:
```
  err := r.createDeployment(ctx, customResource)
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

Do the same type of change when catching the error for creating a service as well:

```
  err = r.createService(ctx, customResource)
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

😌 Running your operator in peace
==============

Once these two changes are in place, try stopping and starting your operator by running `make run` in the `Run Shell`.

You should no longer see any error tracing, only the error log for visibility.


📕 Summary
==============

This is a very simple way to track when a resource already exists. This is where operational tasks like an update process can be codified.

Keep in mind, that different updates may require different actions. For example, adding a label may be simple, but changing image tags may require more caution.

This tutorial will not delve into these nuances due to strict time constraints, but you should have all the tools to tackle these business cases as you reach them!
