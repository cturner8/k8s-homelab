# Kubernetes CRD's

Kustomize deployment to initialise the following application CRD's:
- Cert Manager
- Traefik
- ArgoCD

Having these setup outside the deployment of the relevant charts avoids the deployment dependency that prevents applying any subsequent configurations until the chart deployments are complete.