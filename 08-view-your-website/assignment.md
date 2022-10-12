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
    A website is only fun if it is visible! It is time to expose your todo application outside of Kubernetes.

    **In this challenge you will:**
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
timelimit: 1
---

✅ Some new setup has been completed
==============

Once again, a small helper function has been added to your controller between challenges.

Navigate to `controllers/website_controller.go` in your `Code editor` tab and scroll all the way to the bottom. Here you should find a new function called `newService`.

This function encapsulates the necessary Golang code to create a customized service for your website.

However, just as with the deployment, you still need to call this function in the Reconcile loop.

✍🏾 Creating the service during reconcile
==============

Just as with the deployment method, you need to use the following snippet to call the the new function with the necessary parameters and then catch any errors. Add this snippet directly under the recently added deployment snippet in your reconcile loop (around line 80) making sure to keep the `return` statement as the last line of the `Reconcile` function:
```
  // Attempt to create the service and return error if it fails
  err = r.Client.Create(ctx, newService(customResource.Name, customResource.Namespace))
  if err != nil {
    log.Error(err, fmt.Sprintf(`Failed to create service for website "%s"`, customResource.Name))
    return ctrl.Result{}, err
  }
```

**💾 Once this change is complete. Remember to save the file which with `ctrl+s`.**

> 💡 This needs to be after the call to `newDeployment` since it assumes `err` has already been set. Otherwise you may get an error when trying to run this code.

🛂 Permissions to work with services
=============

Just as with the deployment we need to add permission for the operator to work with services. To do this, add an additional permission to the top of the `controllers/website_controller.go` file around line 47 where the other permissions are listed.

```
//+kubebuilder:rbac:groups=core,resources=services,verbs=get;list;watch;create;update;patch;delete
```

**💾 Once this change is complete. Remember to save the file which with `ctrl+s`.**


✏️ Testing this logic
=============

Since you still haven't handled an update scenario, test this code by actually first deleting the existing deployment and then running your controller.

You may have a pre-existing deployment in your cluster which your operator does not yet know how to react to.  For now to make sure the operator can run successful, run use this command in your `K8s Shell` tab to delete any existing deployments:

```
kubectl delete deployment --selector=type=Website
```

Once deleted, go to the `Run Shell` tab and:
```
make run
```

This will run your controller application again and result in a new deployment being created along with your new service.

See this service by running the following command in your `K8s Shell` tab ✨:

```
kubectl get service --selector=type=Website
```

More excitingly, view the website now in the new `Website` tab next to your `Code editor` tab.

📕 Summary
==============

Application is up! You can check that off your todo list now ☑😉

You can now create an externally accessible webpage given only a minimally configured custom resource. However, once created there really isn't much to do since creating or deleting the Website custom resource causes an error.

You will learn how to detect and then handle these two scenarios in the upcoming challenges.
