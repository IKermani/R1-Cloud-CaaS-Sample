# Define required providers
terraform {
required_version = ">= 0.14.0"
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.53.0"
    }
  }
}


# Configure the OpenStack Provider
provider "openstack" {
  user_name   = var.user_name
  tenant_name = var.tenant_name
  password    = var.password
  auth_url    = var.auth_url
  region      = var.region
}


# Create three VM instances
resource "openstack_compute_instance_v2" "vm" {
  count       = 3
  name        = "vm-${count.index + 1}"
  image_name  = var.image_name
  flavor_name = var.flavor_name

  network {
    name = var.network_name
  }
}

# Open all ingress and egress traffic
resource "openstack_networking_secgroup_v2" "security_group" {
  name        = "allow-all-traffic"
  description = "Security group allowing all ingress and egress traffic"

  rule {
    direction     = "ingress"
    ethertype     = "IPv4"
    remote_ip_prefix = "0.0.0.0/0"
  }

  rule {
    direction     = "egress"
    ethertype     = "IPv4"
    remote_ip_prefix = "0.0.0.0/0"
  }
}

# Attach the security group to each VM
resource "openstack_compute_secgroup_v2" "vm_secgroup" {
  count          = 3
  name           = "vm-${count.index + 1}-secgroup"
  security_group = openstack_networking_secgroup_v2.security_group.id
}

# Output the public IP addresses of the VMs
output "public_ips" {
  value = [for vm in openstack_compute_instance_v2.vm : vm.access_ip_v4]
}
