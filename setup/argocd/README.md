# ArgoCD App Deployment

Kustomize based app deployment for ArgoCD.

Also enables ingress access, applies required patch files to remove HTTPS access enforcement for reverse proxy compatibility and enables SSO with OIDC.

## Deployment Steps

To deploy ArgoCD into the cluster, apply the kustomization file into the `argocd` namespace:

```sh
kubectl apply -k setup/argocd
```

Once ArgoCD is up and running, ensure the `minikube tunnel` is running and access via `https://argocd.kube.kube.local.gd:8443`

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

### Missing CRD's

You may run into an issue during first deployment relating to the missing CRD's when attempting to apply certain manifests. Re-apply and it should work.

**Note**: this was initially a problem when relying on the CRD's being deployed by the ArgoCD helm chart applications and seems to have been resolved by moving those into the dedicated [crds](../crds/README.md) deployment.

### OIDC SSO

The OIDC configuration for ArgoCD SSO is fairly limited in the sense that it does not provide a way to override any specific URL's from the OIDC discovery endpoint (`/.well-known/openid-configuration`).

In practice this means it is not possible to have a "split" configuration where some of these OIDC endpoints point to the external access URL's (e.g. `https://auth.cturner.xyz`) and others pointing to internal cluster service URL's (e.g. `http://server.auth.svc.cluster.local:9000`) which would help avoid any potential DNS related issues, depending on how the relevant DNS for the external access URL is configured.

As a result of the above, the current configuration **does not** utilise the in cluster authentik service, instead opting to use an external, pre-existing authentik deployment due to DNS difficulties when running the cluster locally within minikube. This likely would not be an issue when running in a cloud-based cluster deployment.

