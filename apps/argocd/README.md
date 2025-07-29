# ArgoCD App Deployment

Kustomize based app deployment for ArgoCD.

While not intended to be deployed via ArgoCD directly, it is held within the same main directory as the Argo deployed apps for consistency.

In a real-world cluster deployment, this could be deployed automatically via external CI/CD.

## Deployment Steps

To deploy ArgoCD into the cluster, apply the kustomization file into the `argocd` namespace:

```sh
kubectl apply -n argocd -k apps/argocd
```

Open the minikube dashboard to verify the status of ArgoCD:

```sh
minikube dashboard
```

Once ArgoCD is up and running, access using minikube:

```sh
minikube service argocd-server -n argocd --url=false --https=false
```

This will expose the ArgoCD server on a random available port.

Get the initial admin password from the `argocd-initial-admin-secret` secret. 

Login to the UI using username `admin` and the password from above.