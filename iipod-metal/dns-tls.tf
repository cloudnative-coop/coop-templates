resource "powerdns_record" "a_record" {
  name    = local.dns_fqdn
  zone    = "ii.nz."
  type    = "A"
  ttl     = 60
  records = [equinix_metal_device.iibox.access_public_ipv4]
  # records = [local.elastic_ip]
}

resource "powerdns_record" "wild_a_record" {
  name = "*.${local.dns_fqdn}"
  zone = "ii.nz."
  type = "A"
  ttl  = 60
  # depends_on = [
  #   powerdns_record.a_record
  # ]
  records = [equinix_metal_device.iibox.access_public_ipv4]
  # records = [local.elastic_ip]
}

resource "tls_private_key" "secret" {
  algorithm = "RSA"
  # rsa_bits  = 4096
}

resource "acme_registration" "email" {
  account_key_pem = tls_private_key.secret.private_key_pem
  email_address   = "cert@ii.coop"
}

resource "acme_certificate" "wildcard" {
  account_key_pem           = acme_registration.email.account_key_pem
  common_name               = "*.${local.dns_zone}"
  subject_alternative_names = [local.dns_zone]
  # https://registry.terraform.io/providers/vancluever/acme/latest/docs/guides/dns-providers-pdns#argument-reference
  dns_challenge {
    provider = "pdns"
  }
}
