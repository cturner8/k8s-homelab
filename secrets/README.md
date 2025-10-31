# Cluster Secrets Deployment

Given the kustomize secret files are not synced to git, any app specific secrets need to be manually applied before deployment of the relevant application.

## Secret Definitions

### cloudflare-api-token

Single `api-key` property:

```env
api-token=placeholder_api_token
```

### authentik-postgres-credentials

`username` and `password` properties:

```env
username=authentik
password=random_password
```

Generate a unique password using openssl:

```sh
openssl rand 60 | base64 -w 0
```

### authentik-secret-key

Single `key` property:

```env
key=random_secret_key
```

Generate a unique key using openssl:

```sh
openssl rand 60 | base64 -w 0
```

## Secret Deployment

The secrets are deployed using a standard kustomize file:

```sh
kubectl apply -k .
```

**Note**: this deployment is intentionally not included within the root `kustomization.yml` to ensure the main deployment can be fully automated within ArgoCD.
