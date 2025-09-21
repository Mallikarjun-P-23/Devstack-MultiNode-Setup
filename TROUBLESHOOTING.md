# DevStack Troubleshooting Guide

If you encounter any errors or issues during setup or operation, use the following troubleshooting steps and commands.

---

## 1. Check DevStack Logs

```bash
tail -f /opt/stack/logs/stack.sh.log
tail -f /opt/stack/logs/*
```

---

## 2. Restart DevStack Services

```bash
cd /opt/stack/devstack
./unstack.sh
./clean.sh
./stack.sh
```
---
## 3. Check the MApping of the instacnce 
```bash
  sudo -u stack bash
cd /opt/stack/devstack

# (If not using the stack user, adjust accordingly)
nova-manage cell_v2 discover_hosts --verbose
#After running the above, check for unmapped hosts:
nova-manage cell_v2 list_unmapped_instances
#If it returns nothing, all hosts are now mapped.
```
if any unmapped computes in cell found then on both controller and compute node run the following command 
```bash
sudo systemctl restart devstack@n-cond.service
sudo systemctl restart devstack@n-sch.service
sudo systemctl restart devstack@n-api.service
sudo systemctl restart devstack@n-cpu.service
```

---

## 4. Remove Old Nova State (if compute node issues)

```bash
sudo systemctl stop devstack@n-cpu.service || true
sudo pkill -f nova
sudo rm -rf /etc/nova /var/lib/nova /var/log/nova
sudo rm -rf /opt/stack/logs/*
```

---

## 5. Database Cleanup for Nova (if node registration fails)

```bash
mysql -u root -p
USE nova;
DELETE FROM compute_nodes WHERE hypervisor_hostname = 'OLD_HOSTNAME';
DELETE FROM services WHERE host = 'OLD_HOSTNAME';
exit
```

---

## 6. General Cleanup and Restart

```bash
cd /opt/stack/devstack
./unstack.sh
./clean.sh
sudo rm -rf /etc/nova /var/lib/nova /var/log/nova /opt/stack/logs/*
./stack.sh
```

---

## 7. Reboot the Host (if needed)

```bash
sudo reboot
```

---

## 8. Security Groups & Network Rules

If instances are not accessible:

```bash
# Default security group rules
openstack security group rule create --proto icmp default
openstack security group rule create --proto tcp --dst-port 22 default
openstack security group rule create --proto tcp --dst-port 80 default
openstack security group rule create --proto tcp --dst-port 443 default
openstack security group rule create --egress --proto any default

# Custom group for Cirros
openstack security group create my-secgroup --description "For Cirros"
openstack security group rule create --proto icmp my-secgroup
openstack security group rule create --proto tcp --dst-port 22 my-secgroup
openstack security group rule create --proto tcp --dst-port 80 my-secgroup
openstack security group rule create --egress --proto any my-secgroup
openstack server add security group <instance-id> my-secgroup
```

---

## 9. Check OpenStack Services

```bash

source /opt/stack/devstack/openrc admin admin
openstack compute service list
openstack network agent list
openstack volume service list
openstack service list
openstack hypervisor list
```

---

## 10. Check Hypervisors

```bash
sudo virsh list --all
```

---

## 11. Network Debugging

```bash
# On DevStack host
ip addr
ip route
brctl show
sudo iptables -t nat -L -n -v | grep MASQUERADE

# From inside instance (console)
ip a
ip route
ping <gateway-ip>
ping 8.8.8.8
```

---

## 12. Restarting Individual DevStack Services

```bash
sudo systemctl restart devstack@q-l3.service
sudo systemctl restart devstack@q-dhcp.service
sudo systemctl restart devstack@n-cpu.service
```

---
## 13. Floating IP associating error

```bach
openstack router list
openstack network list
openstack router show router1 # incase u have this router name 
openstack router show r1
openstack router show r2

# after the checking details of router get the subnet ID and add it

openstack router add subnet router1 <subnet ID>

# in case if u want to assign floating ip manually go to the openstack service webpage and associate manually

#else
openstack floating ip set --port <your-port-ip> <your-floating-ip-id>
```

## 14 .For cinder-volume is down in compute 

```bach
sudo nano /etc/cinder/cinder.conf
#here check that volume_driver ,volume_group and backend is their
sudo systemctl restart devstack@c-vol
sudo journalctl -fu devstack@c-vol
#check the volume services
```
## 15. Useful References

- [DevStack Troubleshooting](https://docs.openstack.org/devstack/latest/troubleshooting.html)
- [OpenStack Networking Guide](https://docs.openstack.org/neutron/latest/admin/)
