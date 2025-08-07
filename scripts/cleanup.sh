#!/bin/bash

# DevStack Cleanup Script
# This script helps clean up a DevStack installation

set -e

echo "=== DevStack Cleanup Script ==="
echo "This will clean up your DevStack installation."
echo "WARNING: This will remove all OpenStack data and VMs!"
echo

# Confirm with user
read -p "Are you sure you want to proceed? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Cleanup cancelled."
    exit 1
fi

# Check if we're the stack user
if [[ $USER != "stack" ]]; then
    echo "Switching to stack user..."
    sudo -u stack bash << 'EOF'
    cd /opt/stack/devstack
    
    # Stop all services
    echo "Stopping DevStack services..."
    ./unstack.sh 2>/dev/null || true
    
    # Clean up
    echo "Cleaning DevStack installation..."
    ./clean.sh 2>/dev/null || true
EOF
else
    cd /opt/stack/devstack
    
    # Stop all services
    echo "Stopping DevStack services..."
    ./unstack.sh 2>/dev/null || true
    
    # Clean up
    echo "Cleaning DevStack installation..."
    ./clean.sh 2>/dev/null || true
fi

# Additional cleanup steps
echo "Performing additional cleanup..."

# Clean up any remaining processes
sudo pkill -f "python.*nova" 2>/dev/null || true
sudo pkill -f "python.*neutron" 2>/dev/null || true
sudo pkill -f "python.*keystone" 2>/dev/null || true
sudo pkill -f "python.*glance" 2>/dev/null || true

# Clean up iptables rules (be careful!)
echo "Cleaning up iptables rules..."
sudo iptables -F 2>/dev/null || true
sudo iptables -X 2>/dev/null || true
sudo iptables -t nat -F 2>/dev/null || true
sudo iptables -t nat -X 2>/dev/null || true

# Clean up OVS bridges
echo "Cleaning up OVS bridges..."
sudo ovs-vsctl list-br 2>/dev/null | grep -E "(br-int|br-ex|br-tun)" | while read bridge; do
    sudo ovs-vsctl del-br $bridge 2>/dev/null || true
done

# Remove log files (optional)
read -p "Remove log files? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    sudo rm -rf /opt/stack/logs/* 2>/dev/null || true
    echo "Log files removed."
fi

# Remove data files (optional)
read -p "Remove data files? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    sudo rm -rf /opt/stack/data/* 2>/dev/null || true
    echo "Data files removed."
fi

echo
echo "=== Cleanup Complete ==="
echo "Your system has been cleaned up."
echo "To reinstall DevStack, run:"
echo "1. sudo su - stack"
echo "2. cd devstack"
echo "3. ./stack.sh"
