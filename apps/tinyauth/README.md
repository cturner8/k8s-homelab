# TinyAuth App Deployment

TinyAuth app deployment using Kustomize.

## PocketID Authentication Integration

- Create a new "Tinyauth" OIDC client
- Client Launch URL: public pocketid URL -> `https://tinyauth.kube.dev.cturner.xyz:8443`
- Callback URL: launch URL + callback path -> `https://tinyauth.kube.dev.cturner.xyz:8443/api/oauth/callback/pocketid`
- Ensure "Enable PKCE" is enabled
- Copy Client ID and Client Secret to apply into the cluster secret (see [secrets/readme.md](../../secrets/README.md))
