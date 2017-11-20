
## THIS IS NOT RECOMMENDED FOR PRODUCTION SERVICES.

resource "tls_private_key" "chef" {
  algorithm = "ECDSA"
}

resource "tls_self_signed_cert" "chef" {
  key_algorithm   = "${tls_private_key.chef.algorithm}"
  private_key_pem = "${tls_private_key.chef.private_key_pem}"

  # Certificate expires after X hours.
  validity_period_hours = 12

  # Generate a new certificate if Terraform is run within three
  # hours of the certificate's expiration time.
  early_renewal_hours = 3

  # Reasonable set of uses for a server SSL certificate.
  allowed_uses = [
      "key_encipherment",
      "digital_signature",
      "server_auth",
  ]

  dns_names = ["${var.instance["hostname"]}.${var.instance["domain"]}"]

  subject {
      common_name  = "${var.instance["hostname"]}.${var.instance["domain"]}"
      organization = "${var.instance["domain"]}"
  }
}
