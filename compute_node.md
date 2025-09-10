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
HOST_IP=192.168.0.6 # change this per compute node
FIXED_RANGE=10.4.128.0/20
FLOATING_RANGE=192.168.42.128/25
LOGFILE=/opt/stack/logs/stack.sh.log
ADMIN_PASSWORD=labstack
DATABASE_PASSWORD=supersecret
RABBIT_PASSWORD=supersecret
SERVICE_PASSWORD=supersecret
DATABASE_TYPE=mysql
SERVICE_HOST=192.168.0.5
MYSQL_HOST=$SERVICE_HOST
RABBIT_HOST=$SERVICE_HOST
GLANCE_HOSTPORT=$SERVICE_HOST:9292
ENABLED_SERVICES=n-cpu,c-vol,placement-client,ovn-controller,ovs-vswitchd,ovsdb-server,q-ovn-metadata-agent
NOVA_VNC_ENABLED=True
NOVNCPROXY_URL="http://$SERVICE_HOST:6080/vnc_lite.html"
VNCSERVER_LISTEN=$HOST_IP
VNCSERVER_PROXYCLIENT_ADDRESS=$VNCSERVER_LISTEN
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
