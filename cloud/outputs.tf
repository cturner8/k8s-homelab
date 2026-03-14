output "dns_name_servers" {
  value = module.dns.name_servers
}

output "cert_manager_identity_client_id" {
  value = module.cert_manager_identity.client_id
}
