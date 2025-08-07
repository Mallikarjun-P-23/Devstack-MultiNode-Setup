# DevStack Multinode Setup: Compute Node

## System Requirements
- Ubuntu 22.04 (Jammy) recommended
- At least 4GB RAM, 2 CPUs, 40GB disk
- Static IP (example: `192.168.0.6`)
- Bridged network interface (recommended)

---

## 1. Ubuntu Installation

- Install Ubuntu Server 22.04 with a static IP (set during install or later via netplan).
- Example static IP settings:
  - Address: `192.168.0.6`
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

## 5. Create Compute Node `local.conf`

```ini name=local.conf
[[local|localrc]]
HOST_IP=192.168.0.6
MULTI_HOST=1
ADMIN_PASSWORD=labstack
DATABASE_PASSWORD=labstack
RABBIT_PASSWORD=labstack
SERVICE_PASSWORD=labstack

# Point to controller
SERVICE_HOST=192.168.0.5
MYSQL_HOST=192.168.0.5
RABBIT_HOST=192.168.0.5
GLANCE_HOSTPORT=192.168.0.5:9292

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
PUBLIC_INTERFACE=eth0

# Logging
LOGFILE=/opt/stack/logs/stack.sh.log
```

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

## 8. Troubleshooting

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

## 9. Useful Commands

- View Nova services:
    ```bash
    openstack compute service list
    ```
- View logs:
    ```bash
    tail -f /opt/stack/logs/stack.sh.log
    ```

---

## 10. References

- [DevStack Multinode Guide](https://docs.openstack.org/devstack/latest/guides/multinode-lab.html)
- [DevStack Troubleshooting](https://docs.openstack.org/devstack/latest/troubleshooting.html)

---