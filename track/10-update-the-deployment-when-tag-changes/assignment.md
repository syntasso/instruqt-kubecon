---
slug: update-the-deployment-when-tag-changes
id: l8nj2v0ywovq
type: challenge
title: Update the deployment when imageTag changes
teaser: Now that you detect an update, it can actually update based on your operational
  playbook.
notes:
- type: text
  contents: |-
    The whole value of an operator is to codify the operations for your applications.

    In the last section you identified a possible update scenario. Now you will codify when and how to update the deployment and service.

    **In this challenge you will:**
    * Check the Website custom resource `imageTag` value
    * Check the deployment container tag
    * Use the reconcile function to keep the deployment tag aligned with the custom resource field value
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

📬 Completing your `TODO` item
==============

In the last challenge you captured when a deployment or service already exists. This is because your create code will error and not be able to update an existing resource. While this may seem unreasonable, and solveable by just overwriting with a new create, a create can in some instances differ from an update. For example, you may have certain labels that get added over time that you do not want to remove from a running deployment. You left a `// TODO` comment which you will now complete.

Find your previous `// TODO` comment by navigating in the `Code editor` tab to the `controllers/website_controller.go` file. Specifically look inside the error handling for `newDeployment` (around line 80). It should look like this:

```
err = r.Client.Create(ctx, newDeployment(customResource.Name, customResource.Namespace, customResource.Spec.ImageTag))
if err != nil {
  if errors.IsAlreadyExists(err) {
    log.Info(fmt.Sprintf(`Deployment for website "%s" already exists"`, customResource.Name))
    // TODO: handle updates gracefully
  } else {
    log.Error(err, fmt.Sprintf(`Failed to create deployment for website "%s"`, customResource.Name))
    return ctrl.Result{}, err
  }
}
```

Now in place of the `// TODO` line, you will need to add three things:
1. Current state of the deployment in the cluster
2. Define what the deployment image tag should be
3. Update the deployment if the desired image tag has changed


To complete #1, you need to find the deployment using the name of the resource and store it in a variable to be referenced later. You can do this with the following snippet which should be added instead of the `// TODO` comment line:
```
// Retrieve the current deployment for this website
deploymentNamespacedName := types.NamespacedName{
  Name:      customResource.Name,
  Namespace: customResource.Namespace,
}
deployment := appsv1.Deployment{}
r.Client.Get(ctx, deploymentNamespacedName, &deployment)
```

Now  you need to define the desired state (#2). To do this, you need to check the `Website` custom resource for the value of the `imageTag` field. Add this code directly below the last snippet:

```
// Update can be based on any or all fields of the resource. In this simple operator, only
// the imageTag field which is being provided by the custom resource will be validated.
currentImage := deployment.Spec.Template.Spec.Containers[0].Image
desiredImage := fmt.Sprintf("abangser/todo-local-storage:%s", customResource.Spec.ImageTag)
```

Finally, you want to actually update the current deployment, but only if the image tag has changed. Add the following code after the last two snippets you already added:

```
if currentImage != desiredImage {
  log.Info(fmt.Sprintf(`Image tag has updated from "%s" to "%s"`, currentImage, desiredImage))

  // This operator only cares about the one field, it does not want
  // to alter any other changes that may be acceptable. Therefore,
  // this update will only patch the single field!
  patch := client.StrategicMergeFrom(deployment.DeepCopy())
  deployment.Spec.Template.Spec.Containers[0].Image = desiredImage
  patch.Data(&deployment)

  // Try and apply this patch, if it fails, return the failure
  err := r.Client.Patch(ctx, &deployment, patch)
  if err != nil {
    log.Error(err, fmt.Sprintf(`Failed to update deployment for website "%s"`, customResource.Name))
    return ctrl.Result{}, err
  }
}
```

**💾 Once this change is complete. Remember to save the file with `ctrl+s` (or `⌘ + s` on a mac).**

🎬 Start up the operator again
==============

With this change saved, you can start the operator in the `Run Shell` tab again using `make run`.

The image tag will only change if you change the field value in the `Website` resource. To see this, first change the something else in the `Website`. For example, use the following code in the `K8s Shell` tab to add a label:

```
kubectl label \
  website.kubecon.my.domain \
  website-sample \
  new-label=hello
```

When you look at the log output in the `Run Shell` you should see the log that the deployment already existed, but not the log about a change in imageTag:

```
INFO    Hello from your new website reconciler "latest"!        {"controller": "website"...}
INFO    Deployment for website "website-sample" already exists" {"controller": "website"...}

```

Now let's actually update the image in the `K8s Shell` tab using the following command:

```
kubectl patch \
  website.kubecon.my.domain website-sample \
  --namespace default \
  --type=merge \
  --patch='{"spec":{"imageTag": "v1"}}'
```

You can now see a few things happen.

First, you can see the log lines in the `Run Shell` tab indicate an image tag change:

```
INFO    Hello from your new website reconciler "v1"!    {"controller": "website"...}
INFO    Deployment for website "website-sample" already exists" {"controller": "website"...}
INFO    Image tag has updated from "abangser/todo-local-storage:latest" to "abangser/todo-local-storage:v1"     {"controller": "website"...}
```

Next, you can see the deployment image has been updated to your requested tag:

```
kubectl get deploy \
  --selector type=Website \
  --output jsonpath='{.items[0].spec.template.spec.containers[0]}' | jq
```

Then you can see the pods be replaced with new ones (notice the very young `AGE` value):

```
kubectl get pods
```

<!---
THIS DOES NOT YET WORK - not refreshing on the view

And finally, you can see the tag name in the title of your website in the `Website` tab.

You can continue to update this as frequently as you would like using the [three available tags](https://hub.docker.com/r/abangser/todo-local-storage/tags).
--->

🚷 No need to repeat for the service
==============

You can handle a service update in the same way, however at this stage you don't have a use case for updating the service.

In the future, you may add a new field to the `Website` custom resource that requires a service update and you can use the same technique as above to update it safely.


📕 Summary
==============

You have now not only identified the need to update, but actually codified a safe, targeted application update!

Next you will introduce the final set of functionality for your operator.
