# Cluster Secrets Deployment

Given the kustomize secret files are not synced to git, any app specific secrets need to be manually applied before deployment of the relevant application.

## Secret Definitions

### cloudflare-api-token

Single `api-key` property:

```env
api-token=placeholder_api_token
```

### speedtest-app-key

Single `app-key` property:

```env
app_key=base64:kiioX1ZhC3PmoAN+1wY9tdBN9wWzkBybbmXS16ENrg4=
```

Value should be base64 encoded.

Generate a new value using `openssl`:

```sh
echo -n 'base64:'; openssl rand -base64 32;
```

## Secret Deployment

The secrets are deployed using a standard kustomize file:

```sh
kubectl apply -k .
```

**Note**: this deployment is intentionally not included within the root `kustomization.yml` to ensure the main deployment can be fully automated within ArgoCD.