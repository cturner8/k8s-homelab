# Cluster Secrets Deployment

Given the kustomize secret files are not synced to git, any app specific secrets need to be manually applied before deployment of the relevant application.

## Secret Definitions

### op-api-token

1Password Service Account API token for External Secrets integration.

Single `token` property:

```env
token=placeholder_api_token
```

## Secret Deployment

The secrets are deployed using a standard kustomize file:

```sh
kubectl apply -k .
```

**Note**: this deployment is intentionally not included within the root `kustomization.yml` to ensure the main deployment can be fully automated within ArgoCD.
