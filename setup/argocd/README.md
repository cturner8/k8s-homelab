# ArgoCD App Deployment

Kustomize based app deployment for ArgoCD.

Also enables ingress access, applies required patch files to remove HTTPS access enforcement for reverse proxy compatibility and enables SSO with OIDC.

## Deployment Steps

To deploy ArgoCD into the cluster, apply the kustomization file into the `argocd` namespace:

```sh
kubectl apply -k setup/argocd
```

Once ArgoCD is up and running, ensure the `minikube tunnel` is running and access via `https://argocd.kube.dev.cturner.xyz:8443`

Get the initial admin password from the `argocd-initial-admin-secret` secret using kubectl:

```sh
kubectl \
    -n argocd \
    get secret argocd-initial-admin-secret \
    -o jsonpath="{.data.password}" \
    | base64 --decode
```

Login to the UI using username `admin` and the password from above.

## Known Issues and Workarounds

- You may run into an issue during first deployment relating to the missing CRD's when attempting to apply certain manifests. Re-apply and it should work.