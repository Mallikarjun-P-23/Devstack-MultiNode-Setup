# DevStack Multinode Setup Guide

A comprehensive guide for setting up OpenStack DevStack in a multinode configuration with separate controller and compute nodes.

## 🚀 Overview

This repository serves as a **reference documentation** for setting up OpenStack DevStack in a multinode configuration. The setup has been successfully tested and implemented using virtual machines.

**📝 Note**: This guide is based on a working implementation and serves as documentation for future reference and community use.

### Architecture Components:
- **Controller Node**: Manages OpenStack services (Nova API, Neutron, Horizon, etc.)
- **Compute Node**: Runs virtual machine instances

## 📋 Prerequisites

**✅ Tested Configuration**: This setup has been successfully deployed and tested in a VM environment.

### System Requirements:
- 2+ Ubuntu 22.04 (Jammy) servers or virtual machines
- Each node: 4GB RAM, 2 CPUs, 40GB disk (minimum)
- Static IP addresses configured
- Bridged network interface recommended

### Recommended Deployment Options:
- **Local VMs**: VMware Workstation, VirtualBox, Parallels (tested and working)
- **Cloud VMs**: AWS EC2, Google Cloud, Azure, DigitalOcean instances
- **Hypervisors**: VMware ESXi, Proxmox, KVM
- **Physical Servers**: Bare metal servers in lab/datacenter environments

### VM Configuration Tips:
- Allocate sufficient resources (8GB RAM recommended for smooth operation)
- Enable virtualization features (VT-x/AMD-V) in VM settings
- Use bridged networking for better connectivity between nodes
- Consider NAT with port forwarding as an alternative

## 🏗️ Architecture

```
┌─────────────────┐    ┌─────────────────┐
│  Controller     │    │  Compute Node   │
│  192.168.0.5    │◄──►│  192.168.0.6    │
│                 │    │                 │
│ • Nova API      │    │ • Nova Compute  │
│ • Neutron       │    │ • Neutron Agent │
│ • Horizon       │    │ • Hypervisor    │
│ • MySQL         │    │                 │
│ • RabbitMQ      │    │                 │
│ • Glance        │    │                 │
└─────────────────┘    └─────────────────┘
```

## 📚 Documentation

### Setup Guides
- [Controller Node Setup](controller_nod.md) - Complete controller node configuration
- [Compute Node Setup](compute_node.md) - Complete compute node configuration

### Configuration Files
- [Controller local.conf](configs/controller-local.conf) - Controller node configuration template
- [Compute local.conf](configs/compute-local.conf) - Compute node configuration template
- [Network Configuration](configs/netplan-example.yaml) - Network setup example
- [Configuration Guide](CONFIGURATION.md) - How to customize templates for your environment

**⚠️ Important**: Configuration files contain placeholders like `<controller_ip>`, `<compute_ip>`, etc. See [CONFIGURATION.md](CONFIGURATION.md) for setup instructions.

## 🚦 Quick Start

### 1. Controller Node
```bash
# Follow the controller setup guide
# See: controller_nod.md
```

### 2. Compute Node
```bash
# Follow the compute setup guide  
# See: compute_node.md
```

### 3. Access Dashboard
- URL: http://192.168.0.5/dashboard
- Username: `admin`
- Password: `labstack`

## 🛠️ Scripts

- [setup-controller.sh](scripts/setup-controller.sh) - Automated controller setup
- [setup-compute.sh](scripts/setup-compute.sh) - Automated compute setup
- [cleanup.sh](scripts/cleanup.sh) - Clean up DevStack installation

## 🔧 Configuration

Default network configuration:
- Controller IP: `192.168.0.5`
- Compute IP: `192.168.0.6`
- Network: `192.168.0.0/24`
- Gateway: `192.168.0.1`

**Note**: Modify IP addresses in configuration files to match your environment.

## 🐛 Troubleshooting

### Common Issues

1. **Services not starting**
   ```bash
   tail -f /opt/stack/logs/stack.sh.log
   ```

2. **Network connectivity issues**
   ```bash
   ping controller
   ping compute1
   ```

3. **Clean restart**
   ```bash
   ./unstack.sh
   ./clean.sh
   ./stack.sh
   ```

### Log Locations
- Main logs: `/opt/stack/logs/`
- Stack script log: `/opt/stack/logs/stack.sh.log`
- Service logs: `/opt/stack/logs/[service-name].log`

## 📖 Useful Commands

```bash
# View all OpenStack services
openstack service list

# View compute services
openstack compute service list

# View hypervisors
openstack hypervisor list

# View networks
openstack network list

# View VMs
openstack server list
```

## 🤝 Contributing

Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct and the process for submitting pull requests.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🔗 References

- [Official DevStack Documentation](https://docs.openstack.org/devstack/)
- [DevStack Multinode Guide](https://docs.openstack.org/devstack/latest/guides/multinode-lab.html)
- [OpenStack Documentation](https://docs.openstack.org/)

## ⭐ Support

If you find this guide helpful, please star this repository and share it with others!

---

**Built with ❤️ for the OpenStack community**
