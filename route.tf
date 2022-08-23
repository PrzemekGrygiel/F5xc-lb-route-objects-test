resource "volterra_route" "route-object" {
  count     = var.route_objects  
  name      =  "${var.projectPrefix}-route-object-${count.index}"
  namespace = var.namespace
  dynamic "routes" {
    for_each = aws_instance.vpc1-vms.*.public_ip
    content {
     match {
       path {
          prefix = "/"
       }  
       headers {
        name = "host"
        exact = "school-${((routes.key+1)+(((count.index))*var.instances_number))}.${var.domain}"
        invert_match = false
       }
      }
     route_destination {
      auto_host_rewrite = true
      
      destinations {
       cluster {
        namespace = var.namespace
        name = volterra_cluster.pg-cluster-pool[count.index].name
       }
       weight = 1
       priority = 1
       endpoint_subsets = {
        server = "${routes.key}"
       }
      }
     } 
    }
   } 
  }
