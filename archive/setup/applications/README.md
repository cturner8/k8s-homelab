# ArgoCD Application Manifests

Directory containing ArgoCD Application CRD manifests.

Registers each git based app deployment, targetting a specific app deployment within the `apps` directory. These must be deployed into the `argocd` namespace. 

**Note** this should not contain any helm chart based deployments, these should instead be registered in the `charts` directory.