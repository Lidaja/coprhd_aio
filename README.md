vagrant-coprhd-scaleio-devstack
---------------

# Description

Vagrant environment for 3 ScaleIO VMs, 1 CoprHD VM, and 1 DevStack VM.  Modify the Vagrantfile as needed to configure the network, passwords, etc for your desired setup.

# Prerequisites
* vagrant
  * Nice-to-have: vagrant-cachier for caching packages - really speeds up subsequent installs
  * `vagrant plugin install vagrant-cachier`
* virtualbox

# Usage
* Modify the Vagrantfile for the Host-only network you want to create/use for all VMs
* Launch/Provision all 5 VMs (Full Environment of CoprHD + ScaleIO + Devstack): 
  * `vagrant up`
* Launch only a subset of VM(s)
  * `vagrant up [VM]`
  * [VM] is one or more of: tb, mdm1, mdm2, coprhd, or devstack
  * e.g. To launch only the ScaleIO Cluster: 'vagrant up tb mdm1 mdm2'
  * NOTE: For ScaleIO Cluster provisioning on the first boot, you MUST have mdm2 the last in the list as it does all the cluster creation during provisioning so the other nodes must be running.

# Access the VMs
* `vagrant ssh [VM]`
  * [VM] is one of tb, mdm1, mdm2, coprhd, or devstack 
  * NOTE: Default ssh user is 'vagrant'.  CoprHD sets up services for storageos user.
  * You can either `su storageos` after SSH'ing into CoprHD or you can use this command:
  * `vagrant ssh coprhd -- -l storageos` with the password 'vagrant' to login to CoprHD

# CoprHD Access/Changes
* Login to the CoprHD VM:
  * `vagrant ssh coprhd -- -l storageos`  # P: vagrant
* Stop CoprHD services
  * `sudo /etc/storageos/storageos stop`
* CoprHD source code is in: /tmp/coprhd-controller/
* Checked out branch is: feature-block-service-cinderapi
* Make changes and recompile:
  * `sudo make clobber BUILD_TYPE=oss rpm`

# CoprHD Cli Scripts (https://github.com/curtbruns/coprhd_cli_scripts)
## Location
* coprhd_cli_scripts are cloned in /opt/storageos/coprhd_cli_scripts

##Execution Flow
* Make sure coprhd_settings matches your environment (Passwords, URLs, etc)
* Source the coprhd_settings file
* Choose your desired Config below - either Config1 or Config2

## Config1: CoprHD Setup with ScaleIO (Easy Button)
* ./coprhd -s
* This will add: ScaleIO as a Storage Provider/Backend, ScaleIO network, Virtual Array and Create a ThickSATA Virtual Pool

## Config2: CoprHD Setup with ScaleIO and Devstack and Keystone as Auth Provider
* ./coprhd -o
* This will perform everything in the (Easy Button) step, plus:
* Register Keystone as Auth provider
* Add Admin Tenant and Project
* Update Devstack to use CoprHD as Volume Service
* NOTE: Use the devstack-integration branch to get the kilo Devstack VM enabled

## Tear Everything Down
* ./coprhd -d
* This will delete all traces of CoprHD setup (remove Auth provider, VPool, Varray, Project, Tenant)
  * Note: This doesn't revert the Keystone Endpoint back to Using Cinder as VolumeV2 service

## Check CoprHD Setup
* ./coprhd -c

