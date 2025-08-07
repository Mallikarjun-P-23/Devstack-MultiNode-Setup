# Configuration Setup Instructions

This guide explains how to customize the configuration files for your specific environment.

## 📋 Required Placeholders to Replace

Before using any configuration files or scripts, you **MUST** replace the following placeholders with your actual values:

### Network Configuration Placeholders

| Placeholder | Description | Example |
|------------|-------------|---------|
| `<controller_ip>` | IP address of controller node | `192.168.0.5` |
| `<compute_ip>` | IP address of compute node | `192.168.0.6` |
| `<gateway>` | Network gateway IP | `192.168.0.1` |
| `<network_range>` | Network range for floating IPs | `192.168.0.0` |
| `<interface_name>` | Network interface name | `eth0`, `ens33`, `enp0s3` |

## 🔧 Step-by-Step Configuration

### 1. Copy Configuration Templates

```bash
# Copy controller configuration
cp configs/controller-local.conf ~/devstack/local.conf

# Copy compute configuration (on compute node)
cp configs/compute-local.conf ~/devstack/local.conf
```

### 2. Find Your Network Interface

```bash
# List available network interfaces
ip a

# Common interface names:
# - eth0 (traditional naming)
# - ens33 (VMware)
# - enp0s3 (VirtualBox)
# - ens18 (Proxmox)
```

### 3. Replace Placeholders in Configuration Files

#### Method 1: Manual Editing
```bash
# Edit the local.conf file
vim ~/devstack/local.conf

# Replace all placeholders with your actual values
```

#### Method 2: Using sed (Linux/Mac)
```bash
# Replace placeholders automatically
sed -i 's/<controller_ip>/192.168.0.5/g' ~/devstack/local.conf
sed -i 's/<compute_ip>/192.168.0.6/g' ~/devstack/local.conf
sed -i 's/<interface_name>/eth0/g' ~/devstack/local.conf
sed -i 's/<network_range>/192.168.0.0/g' ~/devstack/local.conf
```

### 4. Update Network Configuration

#### For Netplan (Ubuntu 18.04+)
```bash
# Copy and customize netplan configuration
sudo cp configs/netplan-example.yaml /etc/netplan/01-devstack.yaml

# Edit the file
sudo vim /etc/netplan/01-devstack.yaml

# Replace placeholders:
# <controller_ip> -> your controller IP
# <compute_ip> -> your compute IP  
# <gateway> -> your gateway IP
# <interface_name> -> your interface name

# Apply configuration
sudo netplan apply
```

### 5. Update Hosts File

```bash
# Copy hosts configuration
sudo cp configs/hosts-example /tmp/hosts-devstack

# Edit and replace placeholders
vim /tmp/hosts-devstack

# Append to /etc/hosts
sudo cat /tmp/hosts-devstack >> /etc/hosts
```

## 🚀 Manual Setup Process

Follow the step-by-step guides for manual setup:

### Controller Node
```bash
# Follow the detailed controller setup guide
# See: controller_nod.md

# Make sure to replace placeholders in local.conf before running:
# <controller_ip> -> your controller IP
# <compute_ip> -> your compute IP
# <interface_name> -> your interface name
# <network_range> -> your network range
```

### Compute Node
```bash
# Follow the detailed compute setup guide
# See: compute_node.md

# Make sure to replace placeholders in local.conf before running:
# <controller_ip> -> your controller IP
# <compute_ip> -> your compute IP
# <interface_name> -> your interface name
```

## 📝 Configuration Examples

### Example 1: Home Lab Setup
```bash
# Network: 192.168.1.0/24
<controller_ip>  -> 192.168.1.10
<compute_ip>     -> 192.168.1.11
<gateway>        -> 192.168.1.1
<network_range>  -> 192.168.1.0
<interface_name> -> eth0
```

### Example 2: VMware Workstation
```bash
# Network: 192.168.56.0/24 (Host-only)
<controller_ip>  -> 192.168.56.10
<compute_ip>     -> 192.168.56.11
<gateway>        -> 192.168.56.1
<network_range>  -> 192.168.56.0
<interface_name> -> ens33
```

### Example 3: VirtualBox
```bash
# Network: 10.0.2.0/24 (Bridged)
<controller_ip>  -> 10.0.2.10
<compute_ip>     -> 10.0.2.11
<gateway>        -> 10.0.2.1
<network_range>  -> 10.0.2.0
<interface_name> -> enp0s3
```

### Example 4: Cloud Environment
```bash
# Network: 172.16.0.0/24
<controller_ip>  -> 172.16.0.10
<compute_ip>     -> 172.16.0.11
<gateway>        -> 172.16.0.1
<network_range>  -> 172.16.0.0
<interface_name> -> eth0
```

## ⚠️ Important Notes

1. **IP Addresses**: Ensure both nodes can reach each other
2. **Network Range**: Use the same network range for all nodes
3. **Interface Names**: Check actual interface names with `ip a`
4. **Firewall**: Ensure ports are open between nodes
5. **DNS**: Consider using proper DNS names instead of IPs for production

## 🔍 Verification

After replacing placeholders, verify your configuration:

```bash
# Check network connectivity
ping <controller_ip>
ping <compute_ip>

# Verify interface configuration
ip a show <interface_name>

# Test DNS resolution
nslookup controller
nslookup compute1
```

## 🛠️ Troubleshooting

If you encounter issues:

1. **Double-check all placeholders are replaced**
2. **Verify network connectivity between nodes**
3. **Ensure interface names are correct**
4. **Check firewall settings**
5. **Validate IP address conflicts**

For detailed troubleshooting, see [TROUBLESHOOTING.md](TROUBLESHOOTING.md).
