output "dns_name_servers" {
  value = module.dns.name_servers
}

output "cert_manager_identity_client_id" {
  value = module.cert_manager_identity.client_id
}

output "oauth_proxy_identity_client_id" {
  value = module.oauth_proxy_identity.client_id
}

output "admin_identity_client_id" {
  value = module.admin_identity.client_id
}

output "admin_identity_resource_id" {
  value = module.admin_identity.resource_id
}

output "admin_kv_url" {
  value = module.admin_vault.uri
}

output "kv_url" {
  value = module.vault.uri
}

output "aks_api_url" {
  value = module.aks.private_fqdn
}

output "storage_urls" {
  value = module.storage.fqdn
}
