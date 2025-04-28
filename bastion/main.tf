data "aws_ami" "debian" {
  most_recent = true
  owners      = ["136693071363"]

  filter {
    name   = "name"
    values = ["debian-12-amd64-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "this" {
  ami                         = data.aws_ami.debian.id
  instance_type               = var.instance_type
  key_name                    = var.instance_key
  subnet_id                   = var.instance_subnet
  vpc_security_group_ids      = [aws_security_group.this.id]
  associate_public_ip_address = true
  source_dest_check           = false
  user_data_replace_on_change = true
  user_data = <<EOF
#!/bin/bash -ex
echo 'Port 22' >> /etc/ssh/sshd_config
echo 'Port 10022' >> /etc/ssh/sshd_config
systemctl restart sshd
apt update
apt upgrade -y
DEBIAN_FRONTEND=noninteractive apt install -y iptables-persistent
iptables -t nat -A POSTROUTING -o $(ip -o -4 route show to default | awk '{print $5}') -j MASQUERADE
iptables-save > /etc/iptables/rules.v4
echo net.ipv4.ip_forward=1 > /etc/sysctl.d/10-ip_forward.conf
sysctl -p /etc/sysctl.d/10-ip_forward.conf
EOF

  volume_tags = merge(var.tags,{Name = "${var.name}"})
  tags        = merge(var.tags,{Name = "${var.name}"})

  lifecycle {
    ignore_changes = [ami]
  }
}

resource "aws_security_group" "this" {
  name   = var.name
  vpc_id = var.vpc_id

  dynamic "ingress" {
    for_each = var.public_ports
    content {
      description = ingress.key
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  ingress {
    description = "NAT"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr_block]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = merge(var.tags, {Name = "${var.name}"})
}

resource "aws_route" "this" {
    for_each = toset(var.private_route_table_ids)

    route_table_id              = each.key
    destination_cidr_block      = "0.0.0.0/0"
    network_interface_id        = aws_instance.this.primary_network_interface_id
}
