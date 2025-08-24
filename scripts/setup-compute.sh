#!/bin/bash

# DevStack Compute Node Setup Script
# Usage: ./setup-compute.sh [controller_ip] [compute_ip] [interface]

set -e

# Default values (can be overridden by command line arguments)
CONTROLLER_IP=${1:-"<controller_ip>"}
COMPUTE_IP=${2:-"<compute_ip>"}
INTERFACE=${3:-"eth0"}

echo "=== DevStack Compute Node Setup ==="
echo "Controller IP: $CONTROLLER_IP"
echo "Compute IP: $COMPUTE_IP"
echo "Interface: $INTERFACE"
echo

# Check for placeholder values
if [[ "$CONTROLLER_IP" == "<controller_ip>" || "$COMPUTE_IP" == "<compute_ip>" ]]; then
    echo "ERROR: Please provide actual IP addresses!"
    echo "Usage: $0 <controller_ip> <compute_ip> [interface]"
    echo "Example: $0 192.168.0.5 192.168.0.6 eth0"
    exit 1
fi

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   echo "This script should not be run as root"
   exit 1
fi

# Update system
echo "1. Updating system packages..."
sudo apt update && sudo apt upgrade -y

# Install required packages
echo "2. Installing required packages..."
sudo apt install -y git python3-pip python3-dev build-essential net-tools curl wget

# Create stack user if it doesn't exist
if ! id "stack" &>/dev/null; then
    echo "3. Creating stack user..."
    sudo useradd -s /bin/bash -d /opt/stack -m stack
    echo "stack ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/stack
fi

# Setup hosts file
echo "4. Configuring /etc/hosts..."
sudo tee -a /etc/hosts > /dev/null <<EOF

# DevStack Multinode Setup
$CONTROLLER_IP   controller
$COMPUTE_IP      compute1
EOF

# Switch to stack user and continue setup
echo "5. Switching to stack user for DevStack setup..."
sudo -u stack bash << 'EOF'
cd /opt/stack

# Clone DevStack if not already present
if [ ! -d "devstack" ]; then
    echo "Cloning DevStack..."
    git clone https://opendev.org/openstack/devstack
fi

cd devstack

# Create local.conf for compute node
echo "Creating compute node local.conf..."
cat > local.conf << LOCALCONF
[[local|localrc]]
HOST_IP=COMPUTE_IP_PLACEHOLDER
MULTI_HOST=1
ADMIN_PASSWORD=labstack
DATABASE_PASSWORD=labstack
RABBIT_PASSWORD=labstack
SERVICE_PASSWORD=labstack

# Point to controller
SERVICE_HOST=CONTROLLER_IP_PLACEHOLDER
MYSQL_HOST=CONTROLLER_IP_PLACEHOLDER
RABBIT_HOST=CONTROLLER_IP_PLACEHOLDER
GLANCE_HOSTPORT=CONTROLLER_IP_PLACEHOLDER:9292

# Disable services not needed on compute
disable_service n-net
disable_service q-svc
disable_service q-dhcp
disable_service q-l3
disable_service q-meta
disable_service neutron
disable_service heat
disable_service horizon
disable_service nova-api
disable_service nova-cert
disable_service nova-consoleauth
disable_service nova-scheduler

# Enable compute services
enable_service n-cpu
enable_service q-agt

# Networking
PUBLIC_INTERFACE=<interface_name>

# Logging
LOGFILE=/opt/stack/logs/stack.sh.log
LOCALCONF

EOF

# Replace placeholders in local.conf
sudo -u stack sed -i "s/CONTROLLER_IP_PLACEHOLDER/$CONTROLLER_IP/g" /opt/stack/devstack/local.conf
sudo -u stack sed -i "s/COMPUTE_IP_PLACEHOLDER/$COMPUTE_IP/g" /opt/stack/devstack/local.conf
sudo -u stack sed -i "s/<interface_name>/eth0/g" /opt/stack/devstack/local.conf

echo
echo "=== Setup Complete ==="
echo "IMPORTANT: Make sure the controller node is running first!"
echo "To run DevStack:"
echo "1. sudo su - stack"
echo "2. cd devstack"
echo "3. ./stack.sh"
echo
echo "After completion, verify compute service registration:"
echo "openstack compute service list"

