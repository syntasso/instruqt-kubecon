---
slug: use-crd-data-in-your-controller
id: zddpwbrzlotj
type: challenge
title: Use data defined in the CRD within the controller
teaser: Enhance your generic log line to reference CRD defined data from inside your
  controller.
notes:
- type: text
  contents: |-
    You have seen how requesting a custom resource of type Website can trigger the controller application.

    Now it is time to make the Website CRD truly custom and have the controller use the custom data provided as a part of the CRD spec.

    In this challenge you will:
    * Introduce a new CRD field
    * Reinstall the now updated CRD into Kubernetes
    * Reference the CRD field in the controller
    * Run the updated controller application to test local changes
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
timelimit: 360
---

🆙 Updating the CRD fields
==============

Earlier you had a look at the Golang representation of the CRD. Return to the `Code editor` tab and view this file again by navigating to `api/v1beta1/website_types.go`.

In this CRD there is currently an optional field called `foo` but now we will replace that with a more useful, and required, field called `imageTag`.

Below is the code for this field, use this in the place of the existing `foo` field and comment (lines 31 and 32):

```
  // ImageTag will be used to set the container image for the website to deploy
  //+kubebuilder:validation:Pattern=`^[-a-z0-9]*$`
  ImageTag string `json:"imageTag"`
```

This code has three key parts:

1. `//+kubebuilder` is a comment prefix that will trigger kubebuilder generation changes. In this case, it will set a validation of the field value to only allow dashes, lowercase letters, or digits.
2. The capital `ImageTag` is the Golang variable used throughout the codebase. Golang uses capitalized public variable names by convention.
3. `json:"imageTag"` defines a "tag" that Kubebuilder uses to generate the yaml field. Yaml parameters starts with lower case variable names by convention.

> 💡 the use of `omitempty` in the json tag is how a field is marked optional. This was added to the `foo` example, but since name is required it is not included.

In order to watch the impact of updating this CRD, you can use the `Run Shell` to watch changes to the CRD properties. The following command will print the current values, and then add any changes as a new line:

```
kubectl get crds websites.kubecon.my.domain --output jsonpath="{.spec.versions[0].schema['openAPIV3Schema'].properties.spec.properties}{\"\n\"}" --watch | jq
```

Initially you will see the property `foo`:

```
{
  "foo": {
    "description": "Foo is an example field of Website. Edit website_types.go to remove/update",
    "type": "string"
  }
}
```

Now you can move to the `K8s Shell` tab and rerun:

```
make install
```

Once this command has completed, return to the `Run Shell` tab and you should see a second line in the shell that looks like:

```
{
  "imageTag": {
    "description": "ImageTag sets the container image for the website to deploy",
    "pattern": "^[-a-z0-9]*$",
    "type": "string"
  }
}
```

Now that you have seen this, feel free to stop the "watch" command by pressing `ctrl+c` in the `Run Shell` tab.

You can also see this is required in the CRD by either navigating in the `Code editor` tab or with the following command:

```
kubectl get crd websites.kubecon.my.domain --output jsonpath="{.spec.versions[0].schema.openAPIV3Schema.properties.spec}" | jq
```

> 💡 These kubectl commands are using the built in `jsonpath` output format to narrow in the details displayed about the object and then using [jq](https://stedolan.github.io/jq/) to make the formatting a bit easier to read.


👯‍♂️ Using this field in the controller
==============

Now that there is a new `imageTag` field, you can use this to personalize the log line. Change the existing log line found at `website_controller.go:57` in the controller to:

```
  // Use the `ImageTag` field from the website spec to personalise the log
  log.Info(fmt.Sprintf(`Hello website reconciler with tag "%s"!`, customResource.Spec.ImageTag))
```

Once these changes are made, use the `Run Shell` tab to again run the controller application locally:

```
make run
```

> 💡 If your previous command is still running, use `ctrl+c` to stop that command

As before, this run command may take a bit of time, but when the command completes you should see an initial log line for the existing website request you made in the last challenge. But oops, that log line will not have a personalized name:

```
INFO    Hello website reconciler with tag ""! ...
```

This is because your Website resource does not have an imageTag set. To fix this, edit the existing website request to include an imageTag and you will see the log line use that imageTag.

To edit your website custom resource you can use the `K8s Shell` tab to run:

```
kubectl patch \
  website.kubecon.my.domain website-sample \
  --namespace default \
  --type=merge \
  --patch='{"spec":{"imageTag": "latest"}}'
```

And now you view the controller logs in the `Run Shell` tab to see the newest log line reference your name:

```
INFO    Hello website reconciler with tag "latest"! ...
```

> 💡 If you want to test the validation, try and create a patch with an imageTag that does not match the set requirements of only `-`, lower case alphabet, or digits. The patch should result in an error and the change not applied.

📕 Summary
==============

Fantastic! You now have a controller application that not only responds to a custom resource being added, changed, or deleted but actually uses details from the custom resource in it's logic.
