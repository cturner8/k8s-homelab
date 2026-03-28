## Plan: Harden AKS Cluster with Private Access

Convert the existing public AKS cluster to a private cluster by enabling API Server VNet Integration with private cluster mode, deploying into a BYO VNet, setting up Azure Bastion + jumpbox VM in a peered admin VNet for `kubectl` access, adding private endpoints for Key Vault, and configuring the app routing ingress add-on for the new private topology.

---

### Current State

- AKS uses AVM module `Azure/avm-res-containerservice-managedcluster/azurerm` v0.5.2 with **no explicit VNet** (managed VNet), **public API server**, and **public Key Vault**
- Web App Routing (app routing add-on) with public DNS zone `cloud.cturner.xyz`
- Workload Identity enabled (cert-manager, oauth2-proxy), Flux CD configured but **disabled**
- System-assigned managed identity, Azure AD + Azure RBAC, local accounts disabled

### Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    Admin VNet (10.1.0.0/16)              │
│  ┌──────────────────┐  ┌──────────────────────────────┐ │
│  │ AzureBastionSubnet│  │ Admin VM Subnet (10.1.1.0/24)│ │
│  │  (10.1.0.0/26)   │  │  ┌────────────┐             │ │
│  │  ┌─────────┐     │  │  │ Jumpbox VM │             │ │
│  │  │ Bastion │     │  │  │ (kubectl)  │             │ │
│  │  └─────────┘     │  │  └────────────┘             │ │
│  └──────────────────┘  └──────────────────────────────┘ │
└──────────────┬──────────────────────────────────────────┘
               │ VNet Peering (bidirectional)
┌──────────────┴──────────────────────────────────────────┐
│                    AKS VNet (10.0.0.0/16)               │
│  ┌──────────────────┐  ┌──────────────────────────────┐ │
│  │ API Server Subnet │  │ Node Subnet (10.0.1.0/24)   │ │
│  │  (10.0.0.0/28)   │  │  ┌────────────────────────┐ │ │
│  │  (delegated to   │  │  │ AKS Nodes + Pods       │ │ │
│  │   AKS)           │  │  └────────────────────────┘ │ │
│  └──────────────────┘  └──────────────────────────────┘ │
│  ┌──────────────────────────────────────────────────────┐│
│  │ Private Endpoints Subnet (10.0.2.0/24)              ││
│  │  ┌──────────┐                                       ││
│  │  │ KV PE    │                                       ││
│  │  └──────────┘                                       ││
│  └──────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────┘
```

---

### Steps

**Phase 1: Networking Foundation** — new file `cloud/network.tf`

- [x] **Create AKS VNet** (`10.0.0.0/16`) using an AVM VNet module with subnets:
   - `snet-aks-nodes` (`10.0.1.0/24`) — node pool
   - `snet-aks-apiserver` (`10.0.0.0/28`) — delegated to `Microsoft.ContainerService/managedClusters`
   - `snet-private-endpoints` (`10.0.2.0/24`) — for Key Vault + other private endpoints
- [x] **Create Admin VNet** (`10.1.0.0/16`) with subnets:
   - `AzureBastionSubnet` (`10.1.0.0/26`) — required name, min /26
   - `snet-admin` (`10.1.1.0/24`) — jumpbox VM
- [x] **Create bidirectional VNet peering** between AKS VNet and Admin VNet

**Phase 2: Private AKS Cluster** — modify `cloud/aks.tf`

- [x] **Add `network_profile`** — set `network_plugin = "azure"`, configure `service_cidr`/`dns_service_ip` *(depends on 1)*
- [x] **Update `default_agent_pool`** — set `vnet_subnet_id` to the node subnet *(depends on 1)*
- [x] **Add `api_server_access_profile`** with:
   - `enable_private_cluster = true`
   - `enable_vnet_integration = true`
   - `subnet_id` = API server subnet ID
   - `private_dns_zone = "system"`
   - `enable_private_cluster_public_fqdn = false`
- [x] **Set `public_network_access = "Disabled"`** on the AKS module
- [x] **Switch to user-assigned managed identity** for AKS — required for BYO VNet + private DNS. Assign `Network Contributor` on both subnets. *(depends on 1)*

**Phase 3: Private Endpoints** — modify `cloud/vault.tf`

- [ ] **Harden Key Vault** *(depends on 1)*:
   - Set `public_network_access_enabled = false`, `network_acls.default_action = "Deny"`
   - Add private endpoint in `snet-private-endpoints`
   - Create Private DNS Zone `privatelink.vaultcore.azure.net`, link to both VNets

**Phase 4: Admin Access** — new file `cloud/admin.tf`

- [x] **Deploy Azure Bastion** (Standard SKU) into `AzureBastionSubnet` with a Standard public IP *(depends on 2)*
- [x] **Deploy Jumpbox VM** (`Standard_B2s`, Ubuntu 24.04) into `snet-admin` — no public IP, Bastion-only access. 
- [ ] Cloud-init installs `az cli`, `kubectl`, `kubelogin`, `helm` *(depends on 2)*
- [ ] **Link Private DNS Zones to Admin VNet** — link the AKS private DNS zone (`privatelink.<region>.azmk8s.io`) and Key Vault DNS zone so the jumpbox can resolve private endpoints *(depends on 6, 9)*
- [ ] **RBAC for admin access** — grant admin users `Azure Kubernetes Service RBAC Cluster Admin` on the cluster *(depends on 6)*

**Phase 5: Ingress Strategy** — impacts `apps/` K8s manifests

- [ ] **Ingress decision** — two options:

    | | Option A: Public Ingress (Recommended) | Option B: Fully Private |
    |---|---|---|
    | **Pattern** | Private API server + public-facing apps | Everything private |
    | **Load Balancer** | Public (current default) | Internal LB via `NginxIngressController` annotation |
    | **DNS** | Keep public `cloud.cturner.xyz` zone | Switch to Azure Private DNS Zone |
    | **Changes needed** | **None** to current ingress/DNS setup | Significant — new internal controller, private DNS, VPN for access |
    | **Best for** | Homelab with internet-accessible apps | Enterprise/regulated environments |

    **Recommendation: Option A** — the standard pattern is private API server + public ingress. Your apps remain accessible; only cluster administration is restricted.

- [ ] **NGINX retirement notice** — upstream Ingress NGINX maintenance ended March 2026. Microsoft provides AKS app routing NGINX support through **November 2026**. Plan future migration to the **Gateway API implementation** (`app-routing-gateway-api`). This is independent of the private cluster work.

**Phase 6: CI/CD Considerations**

- [ ] **Flux CD** — no changes needed. Flux runs inside the cluster and communicates with the API server internally. Re-enable when ready.
- [ ] **GitHub Actions** — GitHub-hosted runners **cannot reach** a private API server. Options:
    - `az aks command invoke` — runs kubectl commands via Azure's control plane (no VNet access needed)
    - Self-hosted runner inside the VNet (pod via `actions-runner-controller` or on the jumpbox)
    - **Terraform applies** continue to work — they use the ARM API, not the Kubernetes API

---

### Relevant Files

| File | Action |
|---|---|
| **NEW** `cloud/network.tf` | AKS VNet, Admin VNet, subnets, peering, private DNS zones |
| **NEW** `cloud/admin.tf` | Azure Bastion, jumpbox VM, public IP |
| `cloud/aks.tf` | Add `api_server_access_profile`, `network_profile`, `public_network_access`, update `default_agent_pool.vnet_subnet_id`, switch identity |
| `cloud/vault.tf` | Disable public access, add private endpoint, update `network_acls` |
| `cloud/identity.tf` | Add user-assigned identity for AKS, role assignments for VNet |
| `cloud/variables.tf` | Add variables for CIDR ranges, VM SSH key, VM size |
| `cloud/dns.tf` | Add private DNS zones for Key Vault, link VNet associations |

---

### Verification

1. `terraform plan` — verify changes; expect **cluster recreation** (BYO VNet requires replacement)
2. `terraform apply` — deploy infrastructure
3. Connect to jumpbox via Azure Bastion → `az login` → `az aks get-credentials` → `kubectl get nodes` — confirm private API server access
4. `nslookup <cluster-fqdn>` from jumpbox — confirm private IP resolution
5. From outside the VNet: `kubectl get nodes` — confirm this **fails**
6. `curl https://<app>.cloud.cturner.xyz` — confirm public ingress still works (Option A)
7. Verify Key Vault: confirm `publicNetworkAccess: Disabled` and PE resolves from within VNet

---

### Decisions

- **API Server VNet Integration** over Private Link — simpler, avoids PL limitations, allows toggling private/public without redeployment
- **`private_dns_zone = "system"`** — simpler initial setup; requires manual VNet link for admin VNet to the system-managed DNS zone
- **Cluster recreation** — BYO VNet change from managed VNet forces recreation. Since Flux is disabled and workloads appear stateless, this should be straightforward
- **Ingress: Option A** (public ingress, private API server) unless you need fully private apps
- **Scope exclusions**: Terraform state backend hardening, ACR private endpoint, VPN gateway, Gateway API migration

### Further Considerations

1. **Cluster recreation impact** — If the cluster has state you need to preserve, plan a migration strategy. Since Flux is off and workloads look stateless, a fresh cluster is simplest. Does the cluster currently have running workloads?
2. **Self-hosted GitHub Actions runner** — needed only if CI/CD must run `kubectl` against the cluster. Terraform ARM operations work regardless. Defer unless needed.
3. **Gateway API migration** — app routing NGINX supported through Nov 2026. Tackle independently after private cluster hardening is complete.
