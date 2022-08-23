resource "volterra_cluster" "pg-cluster-pool" {
  count = var.route_objects
  name       = "${var.projectPrefix}-object-pool-${count.index}"
  namespace  = var.namespace
  dynamic "endpoints" {
    for_each = volterra_endpoint.pg-auto-ep.*.name
     content {
       tenant     = var.tenant
       namespace  = var.namespace
       name       = endpoints.value
     }
  }
  loadbalancer_algorithm = "ROUND_ROBIN"
  endpoint_subsets {
      keys = ["server"]
    }
  fallback_policy = "NO_FALLBACK"
  endpoint_selection = "DISTRIBUTED"
}
  
