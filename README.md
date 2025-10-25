# k8s-homelab
Recreation of my Docker Compose based Homelab using Kubernetes and ArgoCD

## Quickstart

A devcontainer configuration file has been pre-configured to install the following tools for local Kubernetes development:
- kubectl
- kustomize (pre-installed with newer versions of kubectl)
- helm

Separate devcontainers have been defined depending on which tool to use for local development:
- minikube
- kind

The devcontainer is also configured to enable "Docker in Docker" to allow spinning up containers from inside the devcontainer.

A local cluster will be created automatically on container startup, depending on which configuration you selected.

If you have Docker installed already, follow [Quick start: Open an existing folder in a container](https://code.visualstudio.com/docs/devcontainers/containers#_quick-start-open-an-existing-folder-in-a-container) to get started.

If you haven't used devcontainers before, see [Getting started](https://code.visualstudio.com/docs/devcontainers/containers#_getting-started) for more details.

If you chose not to use a devcontainer, you'll need to install these tools manually.

## Directory Structure

App deployments are organised into sub-folders of the `apps` directory. 

The content of these app sub-folders can be any application tool supported by ArgoCD (e.g. manifests, kustomize, helm etc.).

Each app sub-folder would then be registered within ArgoCD as an application, targeting the specific sub-folder.

## Deployment

First, setup the deployment secrets, see [secrets/README.md](./secrets/README.md) for full instructions.

**Note**: the secrets deployment is intentionally not included within the root `kustomization.yml` to ensure the main deployment can be fully automated within ArgoCD.

Next, Apply the root `kustomization.yml` file:

```sh
kubectl apply -k .
```

Check the status of the traefik service to confirm ingress access will be active:

```sh
kubectl get svc traefik -n traefik
```

Add the `--watch` or `-w` flag to watch

If the traefik service is running and is accessible, you should see the following output:

```
NAME      TYPE           CLUSTER-IP       EXTERNAL-IP   PORT(S)                         AGE
traefik   LoadBalancer   10.102.205.250   127.0.0.1     8080:30824/TCP,8443:31245/TCP   88s
```

**Note**: The "External IP" will show as pending without a local tunnel running. See [Ingress Access](#ingress-access) for further detail.


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

The traefik service has been setup to expose HTTP port as `8080` and HTTPS port as `8443`, overriding the default `80` and `443` to avoid the elevation requirement to expose these ports locally.

## kind

### Ingress Access

Once traefik is ready, port forward `8080` and `8443` from the traefik service:

```sh
kubectl port-forward svc/traefik 8080 8443 -n traefik
```

This will expose locally on `8080` and `8443`.

## Known Issues

### Cert Manager webhook service not found

During initial apply, the cert manager deployment may fail due to an error such as the following:

```sh
Error from server (InternalError): error when creating ".": Internal error occurred: failed calling webhook "webhook.cert-manager.io": failed to call webhook: Post "https://cert-manager-webhook.cert-manager.svc:443/validate?timeout=30s": service "cert-manager-webhook" not found
```

This seems like it could be related to not having a local tunnel available when using minikube.

Start the tunnel before apply and it should then work. See [Ingress Access](#ingress-access) for further details.