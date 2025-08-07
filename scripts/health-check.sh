#!/bin/bash

# DevStack Health Check Script
# This script checks the health of your DevStack installation

echo "=== DevStack Health Check ==="
echo "Timestamp: $(date)"
echo

# Check if running as stack user
if [[ $USER != "stack" ]]; then
    echo "Note: Some checks require stack user privileges"
    echo "Run 'sudo su - stack' and then run this script for complete check"
    echo
fi

# Function to check service status
check_service() {
    local service_name=$1
    if systemctl is-active --quiet $service_name; then
        echo "✅ $service_name: Running"
    else
        echo "❌ $service_name: Not running"
    fi
}

# Check system resources
echo "=== System Resources ==="
echo "Memory usage:"
free -h
echo
echo "Disk usage:"
df -h /opt/stack
echo

# Check network connectivity
echo "=== Network Connectivity ==="
ping -c 1 controller > /dev/null 2>&1 && echo "✅ Controller reachable" || echo "❌ Controller not reachable"
ping -c 1 compute1 > /dev/null 2>&1 && echo "✅ Compute1 reachable" || echo "❌ Compute1 not reachable"
echo

# Check OpenStack services (if available)
if command -v openstack &> /dev/null; then
    echo "=== OpenStack Services ==="
    
    # Source credentials
    if [[ -f /opt/stack/devstack/openrc ]]; then
        source /opt/stack/devstack/openrc admin admin
        
        echo "Service list:"
        openstack service list 2>/dev/null || echo "❌ Cannot list services"
        echo
        
        echo "Compute services:"
        openstack compute service list 2>/dev/null || echo "❌ Cannot list compute services"
        echo
        
        echo "Network agents:"
        openstack network agent list 2>/dev/null || echo "❌ Cannot list network agents"
        echo
        
        echo "Hypervisors:"
        openstack hypervisor list 2>/dev/null || echo "❌ Cannot list hypervisors"
        echo
    else
        echo "❌ OpenStack credentials not found"
    fi
else
    echo "❌ OpenStack CLI not available"
fi

# Check log files for errors
echo "=== Recent Errors in Logs ==="
if [[ -d /opt/stack/logs ]]; then
    echo "Recent errors in stack.sh.log:"
    tail -50 /opt/stack/logs/stack.sh.log 2>/dev/null | grep -i error | tail -5 || echo "No recent errors found"
    echo
    
    echo "Recent critical errors in nova logs:"
    find /opt/stack/logs -name "*nova*" -exec grep -l "CRITICAL\|ERROR" {} \; 2>/dev/null | head -3 | while read logfile; do
        echo "From $logfile:"
        tail -20 "$logfile" | grep "CRITICAL\|ERROR" | tail -2
    done 2>/dev/null || echo "No critical errors found"
else
    echo "❌ Log directory not found"
fi

echo
echo "=== Health Check Complete ==="
echo "For detailed logs, check: /opt/stack/logs/"
echo "For real-time monitoring: tail -f /opt/stack/logs/stack.sh.log"
