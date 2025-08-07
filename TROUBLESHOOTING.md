# DevStack Multinode Setup - Known Issues and Solutions

This document contains common issues encountered during DevStack multinode setup and their solutions.

## 🚨 Installation Issues

### 1. Stack.sh Fails During Installation

**Problem**: Stack.sh script fails with various errors during installation.

**Common Causes & Solutions**:

#### Memory Issues
```bash
# Error: "Cannot allocate memory"
# Solution: Ensure minimum 4GB RAM, 8GB recommended
free -h
# If insufficient, allocate more memory to your VM
```

#### Network Connectivity
```bash
# Error: Cannot reach controller from compute node
# Solution: Check network configuration
ping controller
ping compute1

# Verify /etc/hosts entries
cat /etc/hosts | grep -E "(controller|compute)"
```

#### Service Start Failures
```bash
# Check specific service logs
tail -f /opt/stack/logs/[service-name].log

# Common services that fail:
# - nova-compute
# - neutron-agent
# - mysql
```

### 2. Neutron Agent Issues

**Problem**: Neutron agents not showing up or in error state.

**Solution**:
```bash
# Check neutron agent status
openstack network agent list

# Restart neutron services
sudo systemctl restart devstack@q-agt
sudo systemctl restart devstack@q-l3
sudo systemctl restart devstack@q-dhcp
```

### 3. Nova Compute Service Not Registered

**Problem**: Compute node not showing in hypervisor list.

**Solution**:
```bash
# On compute node, check nova-compute service
sudo systemctl status devstack@n-cpu

# Check nova-compute logs
tail -f /opt/stack/logs/n-cpu.log

# Verify RabbitMQ connectivity from compute to controller
telnet controller 5672
```

## 🔧 Configuration Issues

### 4. Wrong Interface Configuration

**Problem**: Services binding to wrong network interface.

**Solution**:
```bash
# Check current interfaces
ip a

# Update local.conf with correct interface
# Edit PUBLIC_INTERFACE in local.conf
PUBLIC_INTERFACE=ens33  # or your actual interface

# Restart DevStack
./unstack.sh
./stack.sh
```

### 5. Firewall Blocking Connections

**Problem**: Services cannot communicate between nodes.

**Solution**:
```bash
# Disable UFW temporarily for testing
sudo ufw disable

# Or configure specific ports
sudo ufw allow from 192.168.0.0/24
sudo ufw allow 5672  # RabbitMQ
sudo ufw allow 3306  # MySQL
sudo ufw allow 9292  # Glance
```

### 6. Database Connection Issues

**Problem**: Compute node cannot connect to controller database.

**Solution**:
```bash
# On controller, check MySQL binding
sudo netstat -tlnp | grep 3306

# Edit MySQL configuration if needed
sudo vim /etc/mysql/mysql.conf.d/mysqld.cnf
# Change bind-address = 0.0.0.0

# Restart MySQL
sudo systemctl restart mysql
```

## 🌐 Network Issues

### 7. VM Instances Cannot Get IP Addresses

**Problem**: Launched VMs don't receive IP addresses via DHCP.

**Solution**:
```bash
# Check DHCP agent
openstack network agent list | grep dhcp

# Restart DHCP agent
sudo systemctl restart devstack@q-dhcp

# Check network configuration
openstack network list
openstack subnet list
```

### 8. Floating IP Issues

**Problem**: Cannot assign or access floating IPs.

**Solution**:
```bash
# Check external network configuration
openstack network show external

# Verify router setup
openstack router list
openstack router show router1

# Check iptables rules
sudo iptables -t nat -L
```

## 💻 Performance Issues

### 9. Slow VM Performance

**Problem**: Virtual machines run slowly.

**Solution**:
```bash
# Check hypervisor resources
openstack hypervisor show compute1

# Verify CPU features
grep -E "(vmx|svm)" /proc/cpuinfo

# Check VM flavors
openstack flavor list
```

### 10. High CPU Usage

**Problem**: DevStack services consuming too much CPU.

**Solution**:
```bash
# Check running processes
top -p $(pgrep -d',' python)

# Consider disabling unnecessary services in local.conf
disable_service tempest
disable_service heat
```

## 🔄 Recovery Procedures

### 11. Complete Reset

**Problem**: Need to completely reset DevStack installation.

**Solution**:
```bash
# Run cleanup script
cd ~/devstack
./unstack.sh
./clean.sh

# Optional: Remove all data
sudo rm -rf /opt/stack/data/*
sudo rm -rf /opt/stack/logs/*

# Reinstall
./stack.sh
```

### 12. Partial Service Reset

**Problem**: Only specific services need restart.

**Solution**:
```bash
# Restart specific service
sudo systemctl restart devstack@n-cpu
sudo systemctl restart devstack@q-agt

# Check service status
sudo systemctl status devstack@n-cpu
```

## 🐛 Debugging Tips

### General Debugging Process

1. **Check logs first**:
   ```bash
   tail -f /opt/stack/logs/stack.sh.log
   ```

2. **Verify connectivity**:
   ```bash
   ping controller
   telnet controller 5672
   ```

3. **Check service status**:
   ```bash
   sudo systemctl status devstack@*
   ```

4. **Verify configuration**:
   ```bash
   grep -E "(HOST_IP|SERVICE_HOST)" ~/devstack/local.conf
   ```

### Log File Locations
- Main installation log: `/opt/stack/logs/stack.sh.log`
- Nova compute: `/opt/stack/logs/n-cpu.log`
- Neutron agent: `/opt/stack/logs/q-agt.log`
- System logs: `/var/log/syslog`

### Useful Commands for Troubleshooting
```bash
# Check all DevStack services
sudo systemctl list-units devstack@*

# Monitor logs in real-time
sudo journalctl -f -u devstack@n-cpu

# Network debugging
sudo ovs-vsctl show
sudo ip netns list

# Process monitoring
ps aux | grep nova
ps aux | grep neutron
```

---

For additional help, refer to:
- [DevStack Troubleshooting Guide](https://docs.openstack.org/devstack/latest/troubleshooting.html)
- [OpenStack Documentation](https://docs.openstack.org/)
- [OpenStack Community](https://www.openstack.org/community/)
