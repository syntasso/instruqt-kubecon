---
slug: view-your-website
id: lrtpsez0x5bz
type: challenge
title: View your website by including a service
teaser: Continue to extend the controller. This time include a service that exposes
  your website to public traffic.
notes:
- type: text
  contents: |-
    A website is only fun if it is visible! It is time to expose your to-do application outside of Kubernetes.

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

🕵🏽‍♂️ Some new setup to review
==============

Once again, a small helper function has been added to your controller between challenges.

Navigate to `controllers/website_controller.go` in your `Code editor` tab and scroll all the way to the bottom. Here you should find a new function called `newService`.

This function encapsulates how to create a customized service for your website.

However, just as with the deployment, you still need to call this function in the Reconcile loop.

✍🏾 Creating the service during reconcile
==============

Similar to with deployment method, this function can error. This snippet includes the necessary parameters and handles any errors. Add this snippet directly **under** the recently added deployment snippet in your reconcile loop (around line 80). Make sure to keep the `return` statement as the last line of the `Reconcile` function:
```
  // Attempt to create the service and return error if it fails
  err = r.Client.Create(ctx, newService(customResource.Name, customResource.Namespace))
  if err != nil {
    log.Error(err, fmt.Sprintf(`Failed to create service for website "%s"`, customResource.Name))
    return ctrl.Result{}, err
  }
```

**💾 Once this change is complete. Remember to save the file with `ctrl+s` (or `⌘ + s` on a mac).**

> 💡 This `newService` function needs to be called after the deployment snippet for two reasons. First, if you can't create a deployment and you get an error, you don't need a new service. Creating a deployment is the logical first step. Second, in Golang you use `:=` to declare a new variable and just `=` for overwriting an existing one. Since `err` is defined using the `:=` declaration when you called `newDeployment`, you will get a failure if this service snippet comes first as it won't know how to declare a new variable using only `=`.

🛂 Permissions to work with services
=============

Just as with the deployment we need to add permission for the operator to work with services. Add the following permission to the list of existing permissions at the top of the `controllers/website_controller.go` file (around line 47):

```
//+kubebuilder:rbac:groups=core,resources=services,verbs=get;list;watch;create;update;patch;delete
```

**💾 Once this change is complete. Remember to save the file with `ctrl+s` (or `⌘ + s` on a mac).**

✏️ Testing this logic
=============

This is not as easy as rerunning the controller since updates still are not handled. If you test this code with the previously created deployment, your controller will error.

To be sure you do not have any pre-existing deployments in your cluster , use this command in your `K8s Shell` tab:

```
kubectl delete deployment --selector=type=Website
```

Once any Website deployments have been deleted, go to the `Run Shell` tab and:
```
make run
```
Since you only deleted the deployment and not the Website CRD, running the controller will reconcile the Website and create both a new deployment and now also your new service.

See this service by running the following command in your `K8s Shell` tab ✨:

```
kubectl get service --selector=type=Website
```

More excitingly, view the website now in the new `Website` tab next to your `Code editor` tab.

📕 Summary
==============

Application is up! You can check that off your to-do list now ☑😉

You can now create an externally accessible webpage given a minimally configured custom resource. However, once created there really isn't much to do since creating or deleting the Website custom resource causes an error.

You will learn how to detect and then handle these two scenarios in the upcoming challenges.
