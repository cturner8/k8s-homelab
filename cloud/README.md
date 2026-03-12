# Azure Cloud Infrastructure

## Deployment Bootstrap Process

To prepare for terraform deployments, apply the bootstrap bicep file at the subscription level:

```bash
az deployment sub create \
    --name k8s-homelab-bootstrap \
    --location uksouth \
    --template-file cloud/templates/bootstrap.bicep
```

Optionally provide some parameters:

```bash
az deployment sub create \
    --name k8s-homelab-bootstrap \
    --location uksouth \
    --template-file cloud/templates/bootstrap.bicep \
    --parameters environmentName=prod branchName=main
```

