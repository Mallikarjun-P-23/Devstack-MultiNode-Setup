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
sudo chmod +x /opt/stack
echo "stack ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/stack
sudo su - stack
```

---

## 4 . Add SSH Key
```bash
mkdir ~/.ssh; chmod 700 ~/.ssh
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCyYjfgyPazTvGpd8OaAvtU2utL8W6gWC4JdRS1J95GhNNfQd657yO6s1AH5KYQWktcE6FO/xNUC2reEXSGC7ezy+sGO1kj9Limv5vrvNHvF1+wts0Cmyx61D2nQw35/Qz8BvpdJANL7VwP/cFI/p3yhvx2lsnjFE3hN8xRB2LtLUopUSVdBwACOVUmH2G+2BWMJDjVINd2DPqRIA4Zhy09KJ3O1Joabr0XpQL0yt/I9x8BVHdAx6l9U0tMg9dj5+tAjZvMAFfye3PJcYwwsfJoFxC8w/SLtqlFX7Ehw++8RtvomvuipLdmWCy+T9hIkl+gHYE4cS3OIqXH7f49jdJf jesse@spacey.local" > ~/.ssh/authorized_keys
```
---
## 5. Clone DevStack

```bash
git clone https://opendev.org/openstack/devstack
cd devstack
```

---

## 6. Create Controller `local.conf`

```ini
[[local|localrc]]
HOST_IP=192.168.60.11
FIXED_RANGE=10.4.128.0/20
FLOATING_RANGE=192.168.60.128/25
LOGFILE=/opt/stack/logs/stack.sh.log
ADMIN_PASSWORD=labstack
DATABASE_PASSWORD=supersecret
RABBIT_PASSWORD=supersecret
SERVICE_PASSWORD=supersecret

# Logging
LOGFILE=/opt/stack/logs/stack.sh.log
```

---

## 7. Create Controller  `local.sh`
```ini
for i in `seq 2 10`; 
     do /opt/stack/nova/bin/nova-manage fixed reserve 10.4.128.$i; 
  done
---
```
## 8. Run DevStack

```bash
cd ~/devstack
./stack.sh
```

---

## 9. Set Hostnames (optional if any host error)

Edit `/etc/hosts` on both controller and compute nodes:

```
192.168.60.11   controller
192.168.60.12   compute1
```


---
## create router (optional or create it in horizontal directly)

```bash
# create a router
openstack router create myrouter
# Set the external gateway
openstack router set myrouter --external-gateway public
#Add your internal subnet to the router
openstack router add subnet myrouter <your-subnet-name-or-id>
```
## After successful setup, verify all OpenStack services:

```bash
source /opt/stack/devstack/openrc admin admin
```
```bash
# List all OpenStack services
openstack compute service list
openstack network agent list
openstack volume service list
openstack service list
openstack hypervisor list
```

---

## 11. Mapping and Accessing Instances

### 11.1. Mapping Instances to Networks and Security Groups

- **List Instances with Network Info:**
  ```bash
  openstack server list --long
  ```
  This command displays all instances along with their fixed and floating IP addresses, status, and attached networks.

- **View Detailed Instance Information:**
  ```bash
  openstack server show <instance-name-or-id>
  ```
  Look for the fields `addresses` (for network mapping), `security_groups`, and `OS-EXT-SRV-ATTR:host` (for compute node location).

- **List Security Groups and Rules:**
  ```bash
  openstack security group list           # List all security groups
  openstack security group show <name>    # Show rules for a group
  ```

### 11.2. Example Mapping Table

| Instance Name | Instance ID | Fixed IP      | Floating IP    | Network           | Host Node   | Security Groups    |
|---------------|-------------|---------------|----------------|-------------------|-------------|-------------------|
| cirros-1      | abcd-1234   | 10.4.128.10   | 192.168.60.130 | private-net       | compute1    | default, my-secgroup |

*Use the above commands to fill out this table for your deployment.*

---

### 11.3. Accessing an Instance

- **Assign a Floating IP (if not already assigned):**
  ```bash
  openstack floating ip create <external-network>
  openstack server add floating ip <instance-id> <floating-ip>
  ```
- **SSH to the Instance (if using Cirros or Ubuntu cloud image):**
  ```bash
  ssh cirros@<floating-ip>
  # or for Ubuntu images:
  ssh ubuntu@<floating-ip>
  ```
  *(Use the private key associated with the key pair you specified when launching the instance.)*

---

## 12. Access the Dashboard

- Open: [http://192.168.60.11/dashboard](http://192.168.60.11/dashboard)
- Username: `admin`
- Password: `labstack`

---

## 13. References

- [DevStack Multinode Guide](https://docs.openstack.org/devstack/latest/guides/multinode-lab.html)
- [DevStack Troubleshooting](https://docs.openstack.org/devstack/latest/troubleshooting.html)