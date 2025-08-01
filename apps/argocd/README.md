# ArgoCD App Deployment

Kustomize based app deployment for ArgoCD.

While not intended to be deployed via ArgoCD directly, it is held within the same main directory as the Argo deployed apps for consistency.

In a real-world cluster deployment, this could be deployed automatically via external CI/CD.

## Deployment Steps

To deploy ArgoCD into the cluster, apply the kustomization file into the `argocd` namespace:

```sh
kubectl apply -n argocd -k apps/argocd
```

Once ArgoCD is up and running, ensure the `minikube tunnel` is running and access via `https://argocd.local.gd:8443`

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