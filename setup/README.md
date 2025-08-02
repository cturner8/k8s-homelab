# ArgoCD Setup Deployment

ArgoCD setup `kustomize` deployment which creates an ArgoCD deployment and any associated dependencies.

The deployment currently consists of the following components:

- `crds`: Any required CRD's used in deployed manifest files. This is mainly aimed at chart deployments as the ArgoCD CRD's are bundled within the main installation manifest.
- `certmanager`: Initialise cert manager namespace and certificate issuers. Also registers a secret using a kustomize generator for the ACME DNS Cloudflare API Token. Actual certificate manifests are kept outwith the core cert manager deployment.
- `traefik`: Setup certificates using cert manager issuers for the default traefik TLS store.
- `argocd`: ArgoCD install deployment. Also enables ingress access and applies required patch file to apply the insecure flag in the relevant config map for non-HTTPS access via ingress.
- `applications`: ArgoCD application manifests. Registers each git based app deployment, targetting a specific app deployment within the `apps` directory. These must be deployed into the `argocd` namespace. **Note** this should not contain any helm chart based deployments, these should instead be registered in the `charts` directory.