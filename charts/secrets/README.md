# External Secrets Operator Helm Chart

ESO helm chart deployment via ArgoCD app.

## Requirements

- 1Password Service Account access token in `external-secrets` namespace (see [secrets/README.md](../../secrets/README.md))

## Force Manual Refresh

A secret managed by ESO can be manually refreshed by applying the `force-sync` annotation.

For example, to refresh the `authentik-api-token` secret:

```sh
kubectl annotate es authentik-api-token force-sync=$(date +%s) --overwrite -n authentik
```
