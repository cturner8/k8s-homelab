# Authentik Helm Chart

Authentik helm chart deployment via ArgoCD app.

## Debug Command

Debug helm install command:

```sh
# add repo
helm repo add authentik https://charts.goauthentik.io
helm repo update
# install the release
helm install authentik authentik/authentik -f values.yml --create-namespace -n authentik
# check release status
helm status authentik -n authentik

# verify the authentik server service
kubectl get svc authentik-server -n authentik
# access the authentik server service
minikube service authentik-server -n authentik

# cleanup the release
helm uninstall authentik -n authentik
```

## Known Issues

### Default minikube node resources

When running a local minikube cluster, deploying authentik with the default minikube CPU and Memory limits has lead to pretty sluggish performance, particularly with other application deployments already running within the cluster.

Doubling the default CPU and memory limits leads to better results:

```sh
minikube start --cpus 4 --memory 4g
```

The default minikube storage configuration is not compatible with a multi-node setup so have not been able to confirm if adding additional nodes would also be sufficient. The following [tutorial](https://minikube.sigs.k8s.io/docs/tutorials/multi_node/) on a multi-node setup however does suggest using the available [CSI Driver and Volume Snapshots](https://minikube.sigs.k8s.io/docs/tutorials/volume_snapshots_and_csi/) capability to overcome this restriction.

### PKCE CORS Errors

When attempting to use OIDC SSO within other application deployments, if the relevant app is attempting to reach out to authentik cross-origin (within the browser), these requests will fail when the redirect URL(s) are not configured during setup of the relevant OIDC provider as authentik appears to use these to grant CORS access to any configured URL(s), meaning it is not possible to rely on authentik setting this automatically on first redirect.