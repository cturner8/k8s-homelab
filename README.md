# k8s-homelab
Recreation of my Docker Compose based Homelab using Kubernetes and ArgoCD

## Quickstart

A devcontainer configuration file has been pre-configured to install the following tools for local Kubernetes development:
- minikube
- kubectl
- kustomize (pre-installed with newer versions of kubectl)
- helm

The devcontainer is also configured to enable "Docker in Docker" to allow spinning up containers from inside the devcontainer.

A local minikube cluster will be created automatically on container startup.

If you have Docker installed already, follow [Quick start: Open an existing folder in a container](https://code.visualstudio.com/docs/devcontainers/containers#_quick-start-open-an-existing-folder-in-a-container) to get started.

If you haven't used devcontainers before, see [Getting started](https://code.visualstudio.com/docs/devcontainers/containers#_getting-started) for more details.

If you chose not to use a devcontainer, you'll need to install these tools manually.

## Deploying ArgoCD

To deploy ArgoCD into the cluster, apply the kustomization file:

```sh
kubectl apply -n argocd -k apps/argocd
```

Open the minikube dashboard to verify the status of ArgoCD:

```sh
minikube dashboard
```

Once ArgoCD is up and running, access using minikube:

```sh
minikube service argocd-server -n argocd --url=false --https=false
```

This will expose the ArgoCD server on a random available port.

Get the initial admin password from the `argocd-initial-admin-secret` secret. 

Login to the UI using username `admin` and the password from above.