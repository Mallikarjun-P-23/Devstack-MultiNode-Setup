# DevStack Multinode Setup: Controller Node

## System Requirements
- Ubuntu 22.04 (Jammy) recommended
- At least 4GB RAM, 2 CPUs, 40GB disk
- Static IP (example: `192.168.0.5`)
- Bridged network interface (recommended)

---

## 1. Ubuntu Installation

- Install Ubuntu Server 22.04 with a static IP (set during install or later via netplan).
- Example static IP settings:
  - Address: `192.168.0.5`
  - Netmask: `255.255.255.0`
  - Gateway: `192.168.0.1`
  - DNS: `8.8.8.8`, `8.8.4.4`

---

## 2. Install Required Packages

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y git python3-pip python3-dev build-essential net-tools curl wget
```

---

## 3. Create the `stack` User

```bash
sudo useradd -s /bin/bash -d /opt/stack -m stack
echo "stack ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/stack
sudo su - stack
```

---

## 4. Clone DevStack

```bash
git clone https://opendev.org/openstack/devstack
cd devstack
```

---

## 5. Create Controller `local.conf`

```ini name=local.conf
[[local|localrc]]
HOST_IP=192.168.0.5
MULTI_HOST=1
ADMIN_PASSWORD=labstack
DATABASE_PASSWORD=labstack
RABBIT_PASSWORD=labstack
SERVICE_PASSWORD=labstack

# Networking
FLOATING_RANGE=192.168.0.0/24
PUBLIC_INTERFACE=eth0

# Enable Neutron services
disable_service n-net
enable_service q-svc
enable_service q-agt
enable_service q-dhcp
enable_service q-l3
enable_service q-meta
enable_service neutron

# Enable Compute service on controller (optional for testing)
enable_service n-cpu

# Add Compute Node IPs
COMPUTE_HOSTS=192.168.0.6

# Enable Horizon (dashboard)
enable_service horizon

# Logging
LOGFILE=/opt/stack/logs/stack.sh.log
```

> - Replace `COMPUTE_HOSTS` IP with your compute node(s).
> - Replace `PUBLIC_INTERFACE` (`eth0`) with your actual interface if different (use `ip a`).

---

## 6. Set Hostnames

Edit `/etc/hosts` on both controller and compute nodes:

```
192.168.0.5   controller
192.168.0.6   compute1
```

---

## 7. Run DevStack

```bash
cd ~/devstack
./stack.sh
```

---

## 8. Access the Dashboard

- Open: [http://192.168.0.5/dashboard](http://192.168.0.5/dashboard)
- Username: `admin`
- Password: `labstack`

---

## 9. Troubleshooting

- Check logs: `/opt/stack/logs/`
- Restart services:
    ```bash
    ./unstack.sh
    ./clean.sh
    ./stack.sh
    ```
- Check Hypervisor:  
    ```bash
    sudo virsh list --all
    ```

---

## 10. Useful Commands

- View Nova services:
    ```bash
    openstack compute service list
    ```
- View logs:
    ```bash
    tail -f /opt/stack/logs/stack.sh.log
    ```

---

## 11. References

- [DevStack Multinode Guide](https://docs.openstack.org/devstack/latest/guides/multinode-lab.html)
- [DevStack Troubleshooting](https://docs.openstack.org/devstack/latest/troubleshooting.html)

---