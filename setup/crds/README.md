# Kubernetes CRD's

Kustomize deployment to initialise the following application CRD's:
- Cert Manager
- Traefik
- ArgoCD
- External Secrets Operator

This is mainly aimed at chart deployments as the ArgoCD CRD's are bundled within the main installation manifest.

Having these setup outside the deployment of the relevant charts avoids the deployment dependency that prevents applying any subsequent configurations until the chart deployments are complete.

**Note**: the ESO CRD's require the `--server-side` flag, use `kubectl apply -k setup/crds --server-side` to apply
