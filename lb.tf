resource "volterra_http_loadbalancer" "pg-auto-lb" {
  name                            =  "${var.projectPrefix}-lb"
  namespace                       = var.namespace
  description                     = "HTTPS loadbalancer object ${var.projectPrefix} test"
  #use this to select specific subdomains
  #domains                         = ["school-1.${var.domain}", "school-2.${var.domain}","school-3.${var.domain}","school-4.${var.domain}","school-5.${var.domain}","school-6.${var.domain}","school-7.${var.domain}","school-8.${var.domain}","school-9.${var.domain}","school-10.${var.domain}","school-11.${var.domain}","school-12.${var.domain}","school-13.${var.domain}","school-14.${var.domain}","school-15.${var.domain}","school-16.${var.domain}"]
  #use this to match all subdoains and route using host headers (limit 256 routes)
  domains                         = [ "*.${var.domain}" ]
  advertise_on_public_default_vip = true
  no_service_policies             = true
  disable_rate_limit              = true
  round_robin                     = true
  service_policies_from_namespace = true
  no_challenge                    = true
  dynamic "routes" {
    for_each = volterra_route.route-object.*.name
    content {
     custom_route_object {
       route_ref {
         namespace = var.namespace
         name = "${var.projectPrefix}-route-object-${routes.key}"
       }
     }
    }
  }
  https_auto_cert {
   add_hsts      = false
   http_redirect = false
   no_mtls       = true
  }
}