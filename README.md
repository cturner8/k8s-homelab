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

## Deployment

Apply the root `kustomization.yml` file to get started:

```sh
kubectl apply -k .
```

## minikube 

### Dashboard Access

```sh
minikube dashboard --port 8000
```

### Ingress Access

When running inside the devcontainer, ingress access via Traefik won't resolve by default. 

When starting a tunnel, you need to ensure to set the bind address to a wildcard value:

```sh
minikube tunnel --bind-address='*'
```

If it worked correctly, you should receive an output similar to the following:

```
✅  Tunnel successfully started

📌  NOTE: Please do not close this terminal as this process must stay alive for the tunnel to be accessible ...

🏃  Starting tunnel for service traefik.
```

The traefik service has been setup to expose HTTP port as 8080 and HTTPS port as 8443.

## Known Issues

### Cert Manager webhook service not found

During initial apply, the cert manager deployment may fail du to an error such as the following:

```sh
Error from server (InternalError): error when creating ".": Internal error occurred: failed calling webhook "webhook.cert-manager.io": failed to call webhook: Post "https://cert-manager-webhook.cert-manager.svc:443/validate?timeout=30s": service "cert-manager-webhook" not found
```