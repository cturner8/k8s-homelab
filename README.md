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

## Directory Structure

App deployments are organised into sub-folders of the `apps` directory. 

The content of these app sub-folders can be any application tool supported by ArgoCD (e.g. manifests, kustomize, helm etc.).

Each app sub-folder would then be registered within ArgoCD as an application, targeting the specific sub-folder.

## Deploying ArgoCD

See [apps/argocd/README.md](./apps/argocd/README.md) for ArgoCD deployment steps.

## minikube Ingress Access

When running inside the devcontainer, ingress access via Traefik won't resolve by default. 

When starting a tunnel, you need to ensure to set the bind address to a wildcard value:

```sh
minikube tunnel --bind-address='*'
```

If it worked correctly, you should receive an output similar to the following:

```
✅  Tunnel successfully started

📌  NOTE: Please do not close this terminal as this process must stay alive for the tunnel to be accessible ...

❗  The service/ingress traefik requires privileged ports to be exposed: [80 443]
🔑  sudo permission will be asked for it.
🏃  Starting tunnel for service traefik.
```

The traefik ports 80 and 443 will be forwarded to a random local port, check the "Ports" panel to find it. Check the "Forwarded Address" column for the 80/443 ports.