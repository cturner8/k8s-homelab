resource "random_password" "oauth_proxy_cookie_secret" {
  length           = 32
  override_special = "-_"
}
