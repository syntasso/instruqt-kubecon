# Packer recipe for Backstage specific VM

## Create VM

Pre-req:
* Packer installed locally ([docs](https://developer.hashicorp.com/packer/tutorials/docker-get-started/get-started-install-cli))
* Google project with:
  * Billing enabled
  * Compute enabled
* Host machine must have envvar GHCR_BACKSTAGE set to the value in `lpass show 6412463202117286514 --note | grep GHCR_BACKSTAGE | cut -d ' ' -f 5`

Login with:
```bash
gcloud auth application-default login
```

Then build with:
```bash
PROJECT=<GCP_PROJECT_ID> make build
```
> This is currently built in `instruqt-kubecon` project by default

> If recreating, make sure to use `force-build` target

Takes approximately 8 minutes

## Make VM accessible to Instruqt

Per [docs](https://docs.instruqt.com/concepts/sandboxes/sandbox-hosts/using-custom-public-images#grant-access):

> If you use your virtual machine images, you need to host them publicly or grant them Instruqt access. To grant access, grant the role  roles/compute.imageUser to the Instruqt service account instruqt-track@instruqt-prod.iam.gserviceaccount.com

## Using in track:

Set the `config.yaml` as:
```yaml
virtualmachines:
- name: docker-vm
  image: <GCP_PROJECT_ID>/syntasso-instruqt-hackathon-base-v<VERSION_NUMBER>
  shell: /bin/bash
  machine_type: n1-standard-2
```
