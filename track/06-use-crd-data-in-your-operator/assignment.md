---
slug: use-crd-data-in-your-operator
id: zddpwbrzlotj
type: challenge
title: Use data defined in the CRD within the operator
teaser: Enhance your generic log line to reference CRD defined data from inside your
  operator.
notes:
- type: text
  contents: |-
    You have seen how requesting a custom resource of type Website can trigger the operator reconcile function.

    Now it is time to customizes the Website CRD and use the custom data as a part of the CRD spec.

    **In this challenge you will:**
    * Introduce a new CRD field
    * Reinstall the now updated CRD into Kubernetes
    * Reference the CRD field in the operator
    * Run the updated operator to test local changes
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
difficulty: basic
timelimit: 1
---

🆙 Updating the CRD fields
==============

Earlier you looked at the Golang representation of the CRD. Return to the `Code editor` tab and view this file again by navigating to `api/v1beta1/website_types.go`.

In this CRD there is an optional field called `foo`. Now we will replace that with a more useful, and required, field called `imageTag`.

Below is the code for this field, use this in the place of the existing `foo` field and comment (lines 31 and 32):

```
  // ImageTag will be used to set the container image for the website to deploy
  //+kubebuilder:validation:Pattern=`^[-a-z0-9]*$`
  ImageTag string `json:"imageTag"`
```

**💾 Once this change is complete. Remember to save the file with `ctrl+s` (or `⌘ + s` on a mac).**

This code has three key parts:

1. `//+kubebuilder` is a comment prefix that will trigger kubebuilder generation changes. In this case, it will set a validation of the field value to only allow dashes, lowercase letters, or digits.
2. The capital `ImageTag` is the Golang variable used throughout the codebase. Golang uses capitalized public variable names by convention.
3. `json:"imageTag"` defines a "tag" that Kubebuilder uses to generate the YAML field. Yaml parameters starts with lower case variable names by convention. If you want to learn more about tags in Golang, you can check out [this blog](https://towardsdev.com/golang-struct-tags-explained-ccb589dcbb98) by [Satyajit Roy](https://mobile.twitter.com/__initialized__).

> 💡 the use of `omitempty` in the json tag is how a field is marked as optional. This was present for the `foo` example, but to make name required, you have now removed it.

To see this change in action, use the `Run Shell` to watch changes to the CRD properties. The following command will print the current values, and then add any changes as a new line:

```
kubectl get crds websites.kubecon.my.domain --output jsonpath="{.spec.versions[0].schema['openAPIV3Schema'].properties.spec.properties}{\"\n\"}" --watch | jq
```

For now, you should see the property `foo`:

```
{
  "foo": {
    "description": "Foo is an example field of Website. Edit website_types.go to remove/update",
    "type": "string"
  }
}
```

Now move to the `K8s Shell` tab and rerun:

```
make install
```
Once this command has completed, return to the `Run Shell` tab. Any updates append to the list, so you should now see a second line in the shell that looks like:

```
{
  "imageTag": {
    "description": "ImageTag sets the container image for the website to deploy",
    "pattern": "^[-a-z0-9]*$",
    "type": "string"
  }
}
```

Stop the CRD "watch" command by pressing `ctrl+c` in the `Run Shell` tab.

There are two indications that the new `imageTag` in the CRD is required.

In the `Code editor` tab, look at the `config/crd/bases/kubecon.my.domain_websites.yaml` file. On line 43 there is a required list with `ImageTag`.

Alternatively, you can view this in the cluster. Navigate to the `K8s Shell` tab and run the following command:

```
kubectl get crd websites.kubecon.my.domain --output jsonpath="{.spec.versions[0].schema.openAPIV3Schema.properties.spec}" | jq
```

This is the same required list that you saw in yaml.

> 💡 These kubectl commands are using the built-in `jsonpath` output format to simplify the details displayed for the object and then are using [jq](https://stedolan.github.io/jq/) to make the formatting easier to read.



👯‍♂️ Using this field in the operator
==============

Now that there is a new `imageTag` field, you can personalize the log line. Use your `Code editor` tab to change the existing log line and comment in `website_controller.go` file (around line 67) to instead read:

```
  // Use the `ImageTag` field from the website spec to personalise the log
  log.Info(fmt.Sprintf(`Hello from your new website reconciler with tag "%s"!`, customResource.Spec.ImageTag))
```

**💾 Once this change is complete. Remember to save the file with `ctrl+s` (or `⌘ + s` on a mac).**

Once these changes are saved, navigate to the `Run Shell` tab to again start running the operator application locally:

```
make run
```

> 💡 If your previous command is still running, use `ctrl+c` to stop that command

As before, this run command may take a bit of time. When the command completes you should see an initial log line for the existing website request you made in the last challenge. But oops, that log line will not have a personalized name:

```
INFO    Hello from your new website reconciler ""! ...
```

This is because your Website resource does not have an `imageTag` set. To fix this, you will need to edit the existing website request to include an `imageTag`. To edit your website custom resource to set the `imageTag` field to `latest` use the `K8s Shell` tab to run:

```
kubectl patch \
  website.kubecon.my.domain website-sample \
  --namespace default \
  --type=merge \
  --patch='{"spec":{"imageTag": "latest"}}'
```

And now view the operator logs in the `Run Shell` tab to see the newest log line reference your `imageTag` field value:

```
INFO    Hello from your new website reconciler "latest"! ...
```

> 💡 If you want to test the validation, try and create a patch with an imageTag that does not match the set requirements of only `-`, lower case alphabet, or digits. The patch should result in an error and the change not applied.

📕 Summary
==============

Fantastic! You now have a operator application that not only responds to when a custom resource is added, changed, or deleted but actually uses details from the custom resource in its logic.
