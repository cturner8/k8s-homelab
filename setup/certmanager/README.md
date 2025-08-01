# Cert Manager App Kustomization

Kustomization deployment for Cert Manager.

## ACME DNS Challenge Troubleshooting

Steps to try and debug any DNS challenge issues when generating certs.

Describe certificate:

```sh
kubectl -n cert-manager describe certificate dev-cturner-xyz
```

Describe certificate request:

```sh
kubectl -n cert-manager describe certificaterequest dev-cturner-xyz
```

Describe order:

```sh
kubectl -n cert-manager describe order dev-cturner-xyz
```

Describe challenge:

```sh
kubectl -n cert-manager describe challenge dev-cturner-xyz
```

When a challenge is successfully verified, you should see the following in the events:

```
Type    Reason          Age    From                     Message
----    ------          ----   ----                     -------
Normal  Started         7m40s  cert-manager-challenges  Challenge scheduled for processing
Normal  Presented       7m32s  cert-manager-challenges  Presented challenge using DNS-01 challenge mechanism
Normal  DomainVerified  5m7s   cert-manager-challenges  Domain "kube.dev.cturner.xyz" verified with "DNS-01" validation
```

Once the order is completed:

```sh
Type     Reason    Age                From                 Message
----     ------    ----               ----                 -------
Normal   Created   50m                cert-manager-orders  Created Challenge resource "kube-cturner-xyz-1-3677445741-2690577496" for domain "kube.dev.cturner.xyz"
Normal   Created   50m                cert-manager-orders  Created Challenge resource "kube-cturner-xyz-1-3677445741-3549550428" for domain "kube.dev.cturner.xyz"
Warning  Solver    16m (x2 over 16m)  cert-manager-orders  Failed to determine a valid solver configuration for the set of domains on the Order: no configured challenge solvers can be used for this challenge
Normal   Created   15m                cert-manager-orders  Created Challenge resource "kube-cturner-xyz-1-3677445741-3689494978" for domain "kube.dev.cturner.xyz"
Normal   Created   15m                cert-manager-orders  Created Challenge resource "kube-cturner-xyz-1-3677445741-3495413534" for domain "kube.dev.cturner.xyz"
Normal   Complete  96s                cert-manager-orders  Order completed successfully
```

Once the certificate has been issue:

```sh
Type    Reason     Age    From                                       Message
----    ------     ----   ----                                       -------
Normal  Issuing    51m    cert-manager-certificates-trigger          Issuing certificate as Secret does not exist
Normal  Generated  51m    cert-manager-certificates-key-manager      Stored new private key in temporary Secret resource "kube-cturner-xyz-kjnwt"
Normal  Requested  51m    cert-manager-certificates-request-manager  Created new CertificateRequest resource "kube-cturner-xyz-1"
Normal  Issuing    2m14s  cert-manager-certificates-issuing          The certificate has been successfully issued
```