resource "volterra_endpoint" "pg-auto-ep" {
  name      = "${var.projectPrefix}-endpoint${count.index}"
  namespace = var.namespace
  count     = var.instances_number
  labels = {
     server = "${count.index}"
  }
  protocol  = "TCP"
  port      = 80
  ip        =  aws_instance.vpc1-vms[count.index].public_ip
  where  {
    virtual_network  { 
      ref {
       tenant = "ves-io"
       namespace = "shared"
       name = "public"
      }
    }
 }
}