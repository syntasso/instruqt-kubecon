---
slug: delete-a-website-deployment
id: uocpjfaybikk
type: challenge
title: Delete a website deployment
teaser: The power of operators is handling any drift between requested state and cluster
  state, in this section learn how to detect deletion drift and execute on it
notes:
- type: text
  contents: |-
    Create Read Update and Delete (CRUD) is considered basic functionality for most applciations and an operator is no different.

    So far you have created a deployment and service, but have yet to read, update or delete.

    In this section you will:
    * Detect the deletion of a website
    * Delete any resources the operator creates when it's CRD is deleted
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

👯‍♂️ Why delete is an interesting use case
==============

Now your operator can create new resources, and is ready to deal with updates as well. The last major CRUD functionality is to deal with delete requests.

In order to handle deletes, you will neeed to first identify that the website resource is requesting a delete, and then read the state of the cluster to reconcile any necessary actions in order to complete that delete.


🧑🏽‍🎓 Learning when a resource should be deleted
==============

The process for identifying deletes is not too different from what you did to detect updates.

Once again, there is a specific error which is raised when the Website custom resource is deleted. You will want to catch this error and then add logic to complete the delete process.

Start by running your operator in the `Run Shell` tab using:
```
make run
```

Then delete your current website resource by running the following command in the `K8s Shell` tab:
```
kubectl delete websites.kubecon.my.domain website-sample
```

When you do this, you can see that the deployment and service are still just fine:

```
kubectl get all --selector=type=Website
```

And if you return to the `Run Shell` tab you will see a large set of error messages and stack traces in the operator logs. Something similar to:

```
ERROR   Reconciler error        {"controller": "website", ... "error": "Website.kubecon.my.domain \"website-sample\" not found"}
sigs.k8s.io/controller-runtime/...
        /root/go/pkg/mod/sigs.k8s.io/...
sigs.k8s.io/controller-runtime/pkg/...
        /root/go/pkg/mod/sigs.k8s.io/...
```

> 💡 This error may be repeated many times as the reconcile loop will continue to try and reconcile after failures.

Now you know it is the error `not found` that indicates when the reconcile is occuring on a deleted resource.

🫴🏾 Gracefully catching the delete error
==============

With your new knowledge of a delete error being `not found`, it is time to add a conditional statement into the error block. When you catch the error fetching the custom resource around line 59, you should edit the error block to read:

```
  customResource := &kubeconv1beta1.Website{}
  err := r.Client.Get(context.Background(), req.NamespacedName, customResource)
  if err != nil {
    if errors.IsNotFound(err) {
      // TODO: handle deletes gracefully
      log.Info(fmt.Sprintf(`Custom resource for website "%s" does not exist`, customResource.Name))
      return ctrl.Result{}, nil
    } else {
      log.Error(err, fmt.Sprintf(Failed to retrieve custom resource "%s"`, req.Name))
      return ctrl.Result{}, err
    }
  }
```

Now make sure to retart the operator in your `Run Shell` tab using `ctrl+c` to cancel the previous run and `make run` to restart it.

With the new version of your code running, you can test your change by adding a new Website resource and promptly deleting it from your `K8s Shell` tab:

```
kubectl apply --filename ./config/samples
```

This first command will trigger the update message since you are creating a resource by the same name as before.

But next you need to delete that resource:
```
kubectl delete website.kubecon.my.domain website-sample
```

And when you return to the operator logs now you should see a log line instead of noisy error stack traces.


🔥 Deleting from Kubernetes to match requested state
==============

Catching the desire to delete is not enough. You must also complete the reconcilation by actually deleting any previously created resource.

In this case that will be the deployment and the service. You can find these using the name since your operator provided a specific name when creating the resource.

> 💡 In more complex scenarios you will likely use labels or annotations to create a more robust clean up strategy, but for this scale operator, name will do just fine!


For example, first run in the `K8s Shell` tab the following commands to s:

```
kubectl get deployments --selector=website=website-sample
```
and
```
kubectl get services --selector=website=website-sample
```

Since we know this selector retrieves the correct resources now, it is time to translate this into Golang code. Within the new error catch block,
```

```


📕 Summary
==============

Congratulations! You have now not only identified how to detect a delete, but actually written a basic delete implementation.

While none of these implementations are robust enough for production use, you are well on your way to being able to create an operator with real value to your team.
