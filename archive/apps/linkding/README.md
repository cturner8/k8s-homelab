# Linkding App Deployment

Linkding app deployment using Kustomize.

## Initial Setup for OIDC

When using OIDC for authentication, it is recommended to setup a super user **before** first login with OIDC:

```sh
kubectl exec svc/linkding \
    -n linkding \
    -- python manage.py \
    createsuperuser \
    --username=cturner \
    --email=me@cturner.xyz \
    --no-input
```

This creates a super user with no password set, meaning only login via OIDC is allowed.