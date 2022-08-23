resource "aws_instance" "vpc1-vms" {
  ami                                  = data.aws_ami.ubuntu.id
  count                                = var.instances_number
  tenancy                              = "default"
  ebs_optimized                        = false
  disable_api_termination              = false
  instance_initiated_shutdown_behavior = "stop"
  instance_type                        = "${var.vm_instance_type}"
  key_name                             = "${var.key_name}"
  monitoring                           = false
  vpc_security_group_ids               = [aws_security_group.vpc1_ssh_allowed.id]
  subnet_id                            = aws_subnet.vpc1_private.id
  associate_public_ip_address          = true
  source_dest_check                    = false
  tags = {
    Name = "${var.projectPrefix}-vpc1-vm${count.index+1}"
  }
  connection {
    user        = "ubuntu"
    private_key = "${var.key_path}"
  }
  user_data = <<EOF
#!/bin/bash
while ! ping -c 1 -n -w 1 8.8.8.8 &> /dev/null;do  printf "%c" "."; sleep 5; done
sudo apt update
sudo apt install nginx -y 
echo -e "net.core.rmem_max = 33554432\nnet.core.wmem_max = 33554432\nnet.ipv4.tcp_rmem = 4096 87380 33554432\nnet.ipv4.tcp_wmem = 4096 65536 33554432\nnet.core.netdev_max_backlog = 300000\nfs.file-max = 1048576\nnet.ipv4.tcp_tw_recycle = 1\nnet.ipv4.tcp_tw_reuse = 1\n"   >>  /etc/sysctl.conf 
echo -e "*       soft    nofile  60000\n*       hard    nofile  120000" >> /etc/security/limits.conf
echo -e "worker_rlimit_nofile 60000;" >> /etc/nginx/nginx.conf
sed -i 's/worker_connections 20000;/worker_connections 20000;' /etc/nginx/nginx.conf
sed -i 's/768/20000/' /etc/nginx/nginx.conf
sysctl --system
sleep 5
sudo systemctl enable nginx
sudo systemctl start nginx
echo "School ${count.index+1}" > /var/www/html/index.nginx-debian.html
EOF
}