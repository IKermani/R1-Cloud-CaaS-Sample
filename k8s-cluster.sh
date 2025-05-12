#!/bin/bash

set -xe

# Set the Kubespray version
KUBESPRAY_VERSION=2.23.0
PROJ_DIR=./arvan-test

# Create a working directory
mkdir -p $PROJ_DIR/arvan-test-workspace
cd $PROJ_DIR/arvan-test-workspace

# Get three IPv4 addresses from the user
read -p "Enter the first IPv4 address: " IPV4_ADDRESS1
read -p "Enter the second IPv4 address: " IPV4_ADDRESS2
read -p "Enter the third IPv4 address: " IPV4_ADDRESS3

# Download and install Kubespray
curl -L https://github.com/kubernetes-sigs/kubespray/archive/refs/tags/v${KUBESPRAY_VERSION}.tar.gz | tar xzf -
cd kubespray-${KUBESPRAY_VERSION}

# Ensure that pip is installed
sudo apt-get update
DEBIAN_FRONTEND=noninteractive sudo apt-get -qq install python3-pip sshpass

# Install the Kubespray dependencies
pip install -r requirements.txt

# Preparing Kubespray with the required configurations
cp -rfp ./inventory/sample ./inventory/mycluster
declare -a IPS=("$IPV4_ADDRESS1" "$IPV4_ADDRESS2" "$IPV4_ADDRESS3")
CONFIG_FILE=./inventory/mycluster/hosts.yaml python3 ./contrib/inventory_builder/inventory.py "${IPS[@]}"

# Adding ansible user to hosts.yaml
for IPV4_ADDRESS in "${IPS[@]}"; do
    sed -i "/access_ip: $IPV4_ADDRESS/a \ \ \ \ \ \ ansible_user: $USER" ./inventory/mycluster/hosts.yaml
done

# Configuring addons with the required values
sed -i -e 's/local_path_provisioner_enabled: false/local_path_provisioner_enabled: true/g' ./inventory/mycluster/group_vars/k8s_cluster/addons.yml
sed -i -e 's/ingress_nginx_enabled: false/ingress_nginx_enabled: true/g' ./inventory/mycluster/group_vars/k8s_cluster/addons.yml
sed -i -e 's/# ingress_nginx_host_network: false/ingress_nginx_host_network: true/g' ./inventory/mycluster/group_vars/k8s_cluster/addons.yml
sed -i -e 's/cert_manager_enabled: false/cert_manager_enabled: true/g' ./inventory/mycluster/group_vars/k8s_cluster/addons.yml
sed -i -e 's/argocd_enabled: false/argocd_enabled: true/g' ./inventory/mycluster/group_vars/k8s_cluster/addons.yml

# Create the cluster
ansible-playbook -i inventory/mycluster/hosts.yaml  --become --become-user=root -kK cluster.yml



echo "==================="
echo "==== All done ====="
echo "==================="
