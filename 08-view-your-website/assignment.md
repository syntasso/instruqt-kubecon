---
slug: view-your-website
id: lrtpsez0x5bz
type: challenge
title: View your website
teaser: It is time to bring dog smiles to the world!
notes:
- type: text
  contents: |-
    A website is only fun if it is visible! It is time to expose your dog smile website outside of Kuberentes.

    In this section you will:
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
timelimit: 600
---

✅ Some new setup has been completed
==============

Once again, a small helper function has been added to your controller between sections.

Navigate to `controllers` > `website_controller.go` in your `Code editor` tab and scroll all the way to the bottom. Here you should find a new function called `createService`.

This function encapsulates the necessary Golang code to create a customized service for your website.

However, just as with the deployment, you still need to call this function in the Reconcile loop.

✍🏾 Creating the service during reconcile
==============

Just as with the deployment method, you need to:

1. Call the method from on the `WebReconciler` object
1. Provide both the context (`ctx`) and triggering resource (`customResource`) as parameters
1. Catch and then handle the error return value

The below snippet does all of these things and can be added directly under the deployment snippet in your reconcile loop (around line 72):
```
	err = r.createService(ctx, customResource)
	if err != nil {
		log.Error(err, "Failed to create service")
		return ctrl.Result{}, nil
	}
```

> 💡 This needs to be after the call to `createDeployment` since it assumes `err` has already been set. Otherwise you may get an error when trying to run this code.

✏️ Testing this logic
=============

Since you still haven't handled an update scenario, you can test this code by actually first deleting the existing deployment and then running your controller.

To delete the existing deployment you can run the following command in your `K8s Shell` tab:

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

You now have a website being deployed by your operator 🎉

Unfortunately, it is a one shot deal for now as the operator does not have the logic to deal with updates. But that will be solved in the next section so continue on! 💪🏿