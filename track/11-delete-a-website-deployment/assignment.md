---
slug: delete-a-website-deployment
id: uocpjfaybikk
type: challenge
title: Delete a website deployment
teaser: Drift between operator expectations and cluster reality does not always mean
  update. You must also detect and execute on a deletion of existing websites.
notes:
- type: text
  contents: |-
    Create Read Update and Delete (CRUD) is considered basic functionality for most applications, and an operator is no different. So far you have **created**, handled a simple tag **update** and now it is time to implement **delete**.

    **In this challenge you will:**
    * Detect the deletion of a website
    * Delete any resources the operator creates when its resource is deleted
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

🫥 Why delete is an interesting use case
==============

Now your operator can create new resources, and it is ready to deal with updates. The last major CRUD functionality is to deal with delete requests.

In order to handle deletes, you will need to first identify that the website resource is requesting a delete. Then you will need to read the state of the cluster to find any applicable resources. And finally, you will need to execute a delete on these resources.


🧑🏽‍🎓 Learning when to delete a resource
==============

The process for identifying deletes is not too different from what you did to detect updates.

Once again, there is a specific error which raised when the Website custom resource is deleted. You will want to catch this error and then add logic to complete the delete process.

Start by running your operator in the `Run Shell` tab using:
```
make run
```

Then delete your current website resource by running the following command in the `K8s Shell` tab:
```
kubectl delete websites.kubecon.my.domain website-sample
```

When you do this, the deployment and service are fine and can be viewed with the following command:

```
kubectl get all --selector=type=Website
```

If you return to the `Run Shell` tab you will see a large set of error messages and stack traces in the operator logs.

This time the errors will look similar to:
```
ERROR   Reconciler error        {"controller": "website", ... "error": "Website.kubecon.my.domain \"website-sample\" not found"}
sigs.k8s.io/controller-runtime/...
        /root/go/pkg/mod/sigs.k8s.io/...
sigs.k8s.io/controller-runtime/pkg/...
        /root/go/pkg/mod/sigs.k8s.io/...
```

> 💡 This error may be repeated many times as the reconcile loop will continue to try and reconcile after failures. To stop this use `ctrl+c` to cancel the run.

You can see the `error` is `"Website.kubecon.my.domain \"website-sample\" not found"`. Now you now know that the error type `not found` indicates that the reconciler has run for a deleted resource.

🫴🏾 Gracefully catching the delete error
==============

Knowing that on delete the operator reports `not found` allows you to handle this case independently. Return to `website_controller.go` in your `Code editor` tab and add another conditional statement into the error block.

This error is created when you fetch the custom resource around line 65. The code looks something like:

```
  // Start by declaring the custom resource to be type "Website"
 customResource := &kubeconv1beta1.Website{}

  // Then retrieve from the cluster the resource that triggered this reconciliation.
  // Store these contents into an object used throughout reconciliation.
  err := r.Client.Get(context.Background(), req.NamespacedName, customResource)
  if err != nil {
    // If the resource does not match a "Website" resource type, return failure.
    return ctrl.Result{}, err
  }
```

Edit the this snippet to instead read:

```
  // Start by declaring the custom resource to be type "Website"
  customResource := &kubeconv1beta1.Website{}

  // Then retrieve from the cluster the resource that triggered this reconciliation.
  // Store these contents into an object used throughout reconciliation.
  err := r.Client.Get(context.Background(), req.NamespacedName, customResource)
  if err != nil {
    if errors.IsNotFound(err) {
      // TODO: handle deletes gracefully
      log.Info(fmt.Sprintf(`Custom resource for website "%s" does not exist`, req.Name))
      return ctrl.Result{}, nil
    } else {
      log.Error(err, fmt.Sprintf(`Failed to retrieve custom resource "%s"`, req.Name))
      return ctrl.Result{}, err
    }
  }
```

**💾 Once this change is complete. Remember to save the file with `ctrl+s` (or `⌘ + s` on a mac).**

Restart the operator in your `Run Shell` tab by using `ctrl+c` to cancel the previous run if you haven't already and then using `make run` to start it.

With the new version of your code running, test your change.

From your `K8s Shell` tab, add a new Website resource:
```
kubectl apply --filename ./config/samples/kubecon_v1beta1_website-with-image-tag.yaml
```

This will trigger the update message since you are creating a resource by the same name as before.

Now delete that resource:
```
kubectl delete website.kubecon.my.domain website-sample
```

When you return to the operator logs now you should see a log line instead of noisy error stack traces.
```
INFO    Custom resource for website "website-sample" does not exist
...
```



🔥 Deleting from Kubernetes to match requested state
==============

Catching the desire to delete is not enough. You must also complete the reconciliation by actually deleting any previously created resources.

> 💡 In more complex scenarios you will likely use labels or annotations to create a more robust clean up strategy. For this scale operator, name will do just fine!

You need to delete the deployment and the service resources for the website.

In the `website_controller.go` in your `Code editor` tab replace the three lines of code inside the new error catch block `if errors.IsNotFound(err)` with the following code:

```
// If the resource is not found, that is OK. It just means the desired state is to
// not have any resources for this Website, so we will need to delete them.
log.Info(fmt.Sprintf(`Custom resource for website "%s" does not exist, deleting associated resources`, req.Name))

// Now, try and delete the resource, catch any errors
deployErr := r.Client.Delete(ctx, newDeployment(req.Name, req.Namespace, "n/a"))

// Success for this delete is either:
// 1. the delete is successful without error
// 2. the resource already doesn't exist so delete can't take action
if deployErr != nil && !errors.IsNotFound(deployErr) {
  // If any other error occurs, log it
  log.Error(deployErr, fmt.Sprintf(`Failed to delete deployment "%s"`, req.Name))
  }

// repeat logic from the deployment delete
serviceErr := r.Client.Delete(ctx, newService(req.Name, req.Namespace))
if serviceErr != nil && !errors.IsNotFound(serviceErr) {
  log.Error(serviceErr, fmt.Sprintf(`Failed to delete service "%s"`, req.Name))
  }

// If either the deploy or service deletes fail, the reconcile should fail
if deployErr != nil || serviceErr != nil {
  return ctrl.Result{}, fmt.Errorf("%v/n%v", deployErr, serviceErr)
  }
return ctrl.Result{}, nil
```

**💾 Once this change is complete. Remember to save the file with `ctrl+s` (or `⌘ + s` on a mac).**

💪🏿 Seeing your deletes in action
==============

You need to stop the controller running in the `Run Shell` tab with `ctrl+c` and restart it with `make run`. This will use the new code changes.

Once the controller is restarted, you are now able to exercise your operator in any way you would like.

In particular you can try to create and delete website resources to see the operator clean up after itself with your new code.

Remember to use the following command to see all resources associated with your custom website resources:

```
kubectl get all --selector=type=Website
```

📕 Summary
==============

Congratulations! You have now detected a delete, but you actually wrote a basic implementation of delete.

You are well on your way to being able to create an operator with real value to your team.

If you still have time, continue to the next two challenges for deployment and testing.