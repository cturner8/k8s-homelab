# ArgoCD Apps

Directory for ArgoCD deployment apps.

Any new application should have a manifest registered in [setup/applications/kustomization.yml](../setup/applications/kustomization.yml) to register the app within ArgoCD during apply.

## Applying deployments manually

These deployments can be applied manually using `kubectl` for debugging.

As they are intended to be deployed by ArgoCD however, they will error if the relevant namespace is not created first as this would typically be done by the Argo deployment.

Create a namespace using kubectl:

```sh
kubectl create namespace demo
```

Once finished, the namespace can be completely deleted to cleanup any associated resources:

```sh
kubectl delete namespace demo
```