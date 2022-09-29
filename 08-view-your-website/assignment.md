---
slug: view-your-website
id: lrtpsez0x5bz
type: challenge
title: View your website by including a service
teaser: Continue to extend the controller, this time to include a service that exposes
  your website to public traffic.
notes:
- type: text
  contents: |-
    A website is only fun if it is visible! It is time to expose your dog smile website outside of Kubernetes.

    In this challenge you will:
    * Deploy a service to expose your deployment on a NodePort
    * Use Instruqt to view the website
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
timelimit: 360
---

✅ Some new setup has been completed
==============

Once again, a small helper function has been added to your controller between challenges.

Navigate to `controllers/website_controller.go` in your `Code editor` tab and scroll all the way to the bottom. Here you should find a new function called `createService`.

This function encapsulates the necessary Golang code to create a customized service for your website.

However, just as with the deployment, you still need to call this function in the Reconcile loop.

✍🏾 Creating the service during reconcile
==============

Just as with the deployment method, you need to:

1. Call the method from on the `WebReconciler` object
1. Provide both the context (`ctx`) and triggering resource (`customResource`) as parameters
1. Catch and then handle the error return value

The below snippet does all of these things and can be added directly under the deployment snippet in your reconcile loop (around line 73):
```
  // Attempt to create the service and return error if it fails
  err = r.Client.Create(ctx, newService(customResource.Name, customResource.Namespace))
  if err != nil {
    log.Error(err, fmt.Sprintf(`Failed to create service for website "%s"`, customResource.Name))
    return ctrl.Result{}, err
  }
```

> 💡 This needs to be after the call to `createDeployment` since it assumes `err` has already been set. Otherwise you may get an error when trying to run this code.

✏️ Testing this logic
=============

Since you still haven't handled an update scenario, you can test this code by actually first deleting the existing deployment and then running your controller.

You may have a pre-existing deployment in your cluster which your operator does not yet know how to react to.  For now to make sure the operator can run successful, you can run use this command in your `K8s Shell` tab to delete any existing deployments:

```
kubectl delete deployment --selector=type=Website
```

Once deleted, you can then call `make run` in the `Run Shell` tab and that will run your controller application again and result in a new deployment being created along with your new service.

You can see this service by running the following command in your `K8s Shell` tab:

```
kubectl get service --selector=type=Website
```

More excitingly, you can actually view the website now in the new `Website` tab next to your `Code editor` tab.

📕 Summary
==============

I hope that look of pure join on the dog's face made all your hard work worth it! 🐶

You can now create an externally accessible webpage given only a minimally configured custom resource. However, once created there really isn't much you can do since creating or deleting the Website custom resource causes an error.

You will learn how to detect and then handle these two scenarios in the upcoming challenges.
