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