
[Create a KVM VM using Terraform](https://blog.stephane-robert.info/docs/infra-as-code/provisionnement/terraform/premiere-infra/)

## KVM

### Install

* Check if the kvm module is loaded  
  kvm-md or kvm-intel also have to be loaded — depending on your chipset

  ``` bash
  lsmod | grep -i kvm
  ```

* Install virt-manager — that's a package to create VMs with a GUI, but we're only using it to install all of its dependencies

  ``` bash
  sudo apt install virt-manager
  ```

* Launch libvirt

  ``` bash
  sudo systemctl start libvirtd
  ```

### Setup

To allow terraform to do its thing:

* Edit libvirt configurations

  ``` bash
  sudo vi /etc/libvirt/qemu.conf
  ```

* Update `#security_driver = "selinux"` to `security_driver = "none"`

* Restart libvirt

  ``` bash
  sudo systemctl restart libvirtd
  ```

## Download the image

* For easier debugging: manually get the image and update the root password

  ``` bash
  mkdir local
  cd local

  wget http://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img
  ```

  ``` bash
  sudo apt install -y libguestfs-tools genisoimage
  sudo virt-customize -a jammy-server-cloudimg-amd64.img --root-password password:mysecretpassword

  [   0.0] Examining the guest ...
  [  12.4] Setting a random seed
  virt-customize: warning: random seed could not be set for this type of
  guest
  [  12.4] Setting the machine ID in /etc/machine-id
  [  12.4] Setting passwords
  [  13.5] Finishing off
  ```

### Create a default storage pool

``` bash
# Create the directory
$ sudo mkdir -p /kvm/pools/homelab

# Define the "default" pool
$ sudo virsh pool-define-as --name default --type dir --target /kvm/pools/homelab
Pool default defined

# Start the pool
$ sudo virsh pool-start default
Pool default started

# Set the pool to start at the same time as libvirtd
$ sudo virsh pool-autostart default
Pool default marked as autostarted
```

---

## Launch

* Install terraform plugins

  ```
  $ terraform init
  ```

* Create SSH Keys

  ```
  mkdir .ssh
  ssh-keygen -t ed25519 -b 4096 -f .ssh/id_ed25519
  ```

* Check the plan

  ```
  $ terraform plan
  ```

* Launch it

  ```
  $ sudo terraform apply
  ```

## Check

``` bash
$ sudo virsh list --all
 Id   Name   State
----------------------
 1    test   running

$ sudo virsh net-dhcp-leases default
 Expiry Time           MAC address   Protocol   IP address          Hostname   Client ID or DUID
-----------------------------------------------------------------------------------------------------------------------------------------------
 2024-03-16 11:28:18   ...           ipv4       192.168.122.21/24   ubuntu     ...
```

``` bash
$ terraform output
vm_ips = [
  tolist([
    "192.168.122.21",
  ]),
]
```
``` bash
$ ssh -i .ssh/id_ed25519 ubuntu@192.168.122.21
Welcome to Ubuntu 22.04.4 LTS (GNU/Linux 5.15.0-100-generic x86_64)

ubuntu@test:~$ 
```

## Clean up

```
$ sudo terraform destroy -auto-approve
```
