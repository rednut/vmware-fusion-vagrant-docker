# -*- mode: ruby -*-
# vi: set ft=ruby :

BOX_NAME = ENV['BOX_NAME'] || "ubuntu_precise_14_01"
BOX_URI = ENV['BOX_URI'] || "http://files.vagrantup.com/precise64.box"
VF_BOX_URI = ENV['BOX_URI'] || "https://oss-binaries.phusionpassenger.com/vagrant/boxes/latest/ubuntu-14.04-amd64-vmwarefusion.box"
AWS_BOX_URI = ENV['BOX_URI'] || "https://github.com/mitchellh/vagrant-aws/raw/master/dummy.box"
AWS_REGION = ENV['AWS_REGION'] || "us-east-1"
AWS_AMI = ENV['AWS_AMI'] || "ami-69f5a900"
AWS_INSTANCE_TYPE = ENV['AWS_INSTANCE_TYPE'] || 't1.micro'
SSH_PRIVKEY_PATH = ENV['SSH_PRIVKEY_PATH']
PRIVATE_NETWORK = ENV['PRIVATE_NETWORK']
APT_CACHER = ENV['APT_CACHER']


# Boolean that forwards the Docker dynamic ports 49000-49900
# See http://docs.docker.io/en/latest/use/port_redirection/ for more
# $ FORWARD_DOCKER_PORTS=1 vagrant [up|reload]
FORWARD_DOCKER_PORTS = ENV['FORWARD_DOCKER_PORTS']
VAGRANT_RAM = ENV['VAGRANT_RAM'] || "2048"
VAGRANT_CORES = ENV['VAGRANT_CORES'] || "4"
VAGRANT_BOXNAME = ENV['VAGRANT_BOXNAME'] || "docker1"
VAGRANT_ANNOTATION = ENV['VAGRANT_ANNOTATION'] || "docker host"

# You may also provide a comma-separated list of ports
# for Vagrant to forward. For example:
# $ FORWARD_PORTS=8080,27017 vagrant [up|reload]
FORWARD_PORTS = ENV['FORWARD_PORTS'] || "4243"

# A script to upgrade from the 12.04 kernel to the raring backport kernel (3.8)
# and install docker.
$script = <<SCRIPT
set -e
set -x


export DEBIAN_FRONTEND=noninteractive
export DOCKER_PORT=4243
export APT_CACHER="#{APT_CACHER}"

# include common util funcs
source /vagrant/scripts/netif.functions.sh
source /vagrant/scripts/common.functions.sh


# The username to add to the docker group will be passed as the first argument
# to the script.  If nothing is passed, default to "vagrant".
user="$1"
if [ -z "$user" ]; then
    user=vagrant
fi


# check /vagrant directy is present and if  mounted unmount it
isdir /vagrant || die 42 "/vagrant is not a directory"
#isdir /data    || die 42 "/data is not a directory"

# unmount all vmhgfs mounts
umount -t vmhgfs -a -v || die 61 "problem performing umount of vmhgfs mounts"

# double check we have /data and /vagrant unmounted
ismounted /vagrant \
  && { die 99 "still mounted: /vagrant" ; } \
  || echo "/vagrant is not mounted"
#ismounted /data \
#  && { die 99 "still mounted: /data" ; } \
#  || echo "/data is not mounted"


# restart vmware services
/etc/vmware-tools/services.sh restart || die 98 "cannot restartvmware services"

# remount shared dirs
mount -t vmhgfs .host:/-vagrant /vagrant || die 97 "cannot mount /vagrant"
#mount -t vmhgfs .host:/-data /data || die 96 "cannot mount /data"

# check sanity
isfile /vagrant/.empty || die 46 "no data in /vagrant shared mount after vmware tools restart" 
#isfile /data/.empty    || die 46 "no data in /data shared vmhgfs mount"

# check access to scritps dir
isdir /vagrant/scripts \
  || die 42 "/vagrant/scripts directory is missing"
isfile /vagrant/scripts/netif.functions.sh \
      || die 42 "netif.functions.sh is missing from /vagrant/scripts"

# if we have ENV[APT_CACHER] set then use it
APT_PROXY_FILE=/etc/apt/apt.conf.d/01proxy
[[ ! -z "$APT_CACHER" ]] \
  && { echo "APT_CACHER_PROXY=$APT_CACHER" ; \
       echo 'Acquire::http { Proxy "$APT_CACHER"; };'  > "$APT_PROXY_FILE"; } \
  || { echo 'No APT CACHER PROXY ENV VAR SUPPLIED'; rm -vf "$APT_PROXY_FILE"; }
  

# use local mirror for apt
sed -i \
    's#//us\.#//gb\.#g' \
    /etc/apt/sources.list

# Enable memory cgroup and swap accounting
sed -i \
      's/GRUB_CMDLINE_LINUX=""/GRUB_CMDLINE_LINUX="cgroup_enable=memory swapaccount=1"/g' \
      /etc/default/grub

# update initial ramdisks
update-grub

# Adding an apt gpg key is idempotent.
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 36A1D7869245C8950F966E92D8576A8BA88D21E9

# Creating the docker.list file is idempotent, but it may overwrite desired
# settings if it already exists.  This could be solved with md5sum but it
# doesn't seem worth it.
echo 'deb http://get.docker.io/ubuntu docker main' > /etc/apt/sources.list.d/docker.list

# Update remote package metadata.  'apt-get update' is idempotent.
apt-get  update -q -y

# Install docker.  'apt-get install' is idempotent.
apt-get install -q -y lxc-docker

# make listen on tcp socket
#sed -i 's/DOCKER_OPTS=$/DOCKER_OPTS=-H tcp:\/\/0.0.0.0:4243 -H unix:\/\/\/var\/run\/docker.sock/g' /etc/init/docker.conf
#sed -i 's/DOCKER_OPTS=$/DOCKER_OPTS=-H tcp:\/\/0.0.0.0:4243 -H unix:\/\/\/var\/run\/docker.sock/g' /etc/init.d/docker

# set docker opts to listen on all if's port $DOCKER_PORT
grep 'tcp://0.0.0.0:4243' /etc/default/docker \
  || echo 'DOCKER_OPTS="-H tcp://0.0.0.0:4243 $DOCKER_OPTS"' >> /etc/default/docker

# set docker listen to unit socket if not set
grep 'unix://var/run/docker.dock' /etc/default/docker \
  || echo 'DOCKER_OPTS="-H unix:///var/run/docker.sock $DOCKER_OPTS"' >> /etc/default/docker

cat /etc/default/docker

usermod -a -G docker "$user"


# create data directory for docker persistence for this host in
mkdir -pv /vagrant/data/$HOSTNAME/docker/
# ensure we can write to it
chmod -Rv a+rwx /vagrant/data/$HOSTNAME/

# sym link from vagrant mount for this host to /data
ln -fs /vagrant/data/$HOSTNAME/ /data
touch /data/.$HOSTNAME


  # write network interface state
  if-addr-writer \
        "/data/state" \
        eth0 \
        docker0

# restart docker
service docker restart

# show docker process
ps -aux | grep docker

# test connection to interweb
ping -c3 8.8.8.8

ifconfig eth0
echo 
echo "Docker has been provisioned!"
echo
echo "set you DOCKER_IP="`cat /data/state/eth0`

SCRIPT

# We need to install the virtualbox guest additions *before* we do the normal
# docker installation.  As such this script is prepended to the common docker
# install script above.  This allows the install of the backport kernel to
# trigger dkms to build the virtualbox guest module install.
$vbox_script = <<VBOX_SCRIPT + $script
# Install the VirtualBox guest additions if they aren't already installed.
if [ ! -d /opt/VBoxGuestAdditions-4.3.6/ ]; then
    # Update remote package metadata.  'apt-get update' is idempotent.
    apt-get update -q

    # Kernel Headers and dkms are required to build the vbox guest kernel
    # modules.
    apt-get install -q -y linux-headers-generic-lts-raring dkms

    echo 'Downloading VBox Guest Additions...'
    wget -cq http://dlc.sun.com.edgesuite.net/virtualbox/4.3.6/VBoxGuestAdditions_4.3.6.iso
    echo "95648fcdb5d028e64145a2fe2f2f28c946d219da366389295a61fed296ca79f0  VBoxGuestAdditions_4.3.6.iso" | sha256sum --check || exit 1

    mount -o loop,ro /home/vagrant/VBoxGuestAdditions_4.3.6.iso /mnt
    /mnt/VBoxLinuxAdditions.run --nox11
    umount /mnt
fi
VBOX_SCRIPT

Vagrant::Config.run do |config|
  # Setup virtual machine box. This VM configuration code is always executed.
  config.vm.box = BOX_NAME
  config.vm.box_url = BOX_URI
  config.vm.host_name = VAGRANT_BOXNAME

  # Use the specified private key path if it is specified and not empty.
  if SSH_PRIVKEY_PATH
      config.ssh.private_key_path = SSH_PRIVKEY_PATH
  end

  config.ssh.forward_agent = true
end

# Providers were added on Vagrant >= 1.1.0
#
# NOTE: The vagrant "vm.provision" appends its arguments to a list and executes
# them in order.  If you invoke "vm.provision :shell, :inline => $script"
# twice then vagrant will run the script two times.  Unfortunately when you use
# providers and the override argument to set up provisioners (like the vbox
# guest extensions) they 1) don't replace the other provisioners (they append
# to the end of the list) and 2) you can't control the order the provisioners
# are executed (you can only append to the list).  If you want the virtualbox
# only script to run before the other script, you have to jump through a lot of
# hoops.
#
# Here is my only repeatable solution: make one script that is common ($script)
# and another script that is the virtual box guest *prepended* to the common
# script.  Only ever use "vm.provision" *one time* per provider.  That means
# every single provider has an override, and every single one configures
# "vm.provision".  Much saddness, but such is life.
Vagrant::VERSION >= "1.1.0" and Vagrant.configure("2") do |config|
  config.vm.provider :aws do |aws, override|
    username = "ubuntu"
    override.vm.box_url = AWS_BOX_URI
##    override.vm.provision :shell, :inline => $script, :args => username
    override.vm.provision :shell, :path => "provisioning/providers/aws.sh", :args => username
    override.vm.provision :shell, :path => "provisioning/dockerhost.sh", :args => username

    aws.access_key_id = ENV["AWS_ACCESS_KEY"]
    aws.secret_access_key = ENV["AWS_SECRET_KEY"]
    aws.keypair_name = ENV["AWS_KEYPAIR_NAME"]
    override.ssh.username = username
    aws.region = AWS_REGION
    aws.ami    = AWS_AMI
    aws.instance_type = AWS_INSTANCE_TYPE
  end

  config.vm.provider :rackspace do |rs, override|
 #   override.vm.provision :shell, :inline => $script
    override.vm.provision :shell, :path => "provisioning/providers/rackspace.sh"
    override.vm.provision :shell, :path => "provisioning/dockerhost.sh"
    rs.username = ENV["RS_USERNAME"]
    rs.api_key  = ENV["RS_API_KEY"]
    rs.public_key_path = ENV["RS_PUBLIC_KEY"]
    rs.flavor   = /512MB/
    rs.image    = /Ubuntu/
  end

  config.vm.provider :vmware_fusion do |f, override|
    override.vm.box_url = VF_BOX_URI
    override.vm.synced_folder "./", "/vagrant"
    #override.vm.synced_folder "data/", "/data"
    ##override.vm.synced_folder "./data", "/data", disabled: false
    override.vm.provision :shell, :inline => $script
    override.vm.provision :shell, :path => "provisioning/providers/vmware_fusion.sh"
    override.vm.provision :shell, :path => "provisioning/dockerhost.sh"
    f.vmx["displayName"] = VAGRANT_BOXNAME
    f.vmx["memsize"] = VAGRANT_RAM
    f.vmx["numvcpus"] = VAGRANT_CORES
    f.vmx["annotation"] = VAGRANT_ANNOTATION
  end

  config.vm.provider :virtualbox do |vb, override|
    #override.vm.provision :shell, :inline => $vbox_script
    override.vm.provision :shell, :path => "provisioning/providers/virtualbox.sh"
    override.vm.provision :shell, :path => "provisioning/dockerhost.sh"
    vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
    vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
    vb.customize ["modifyvm", :id, "--memory", VAGRANT_RAM]
    vb.customize ["modifyvm", :id, "--cpus", VAGRANT_CORES]
  end
end

# If this is a version 1 config, virtualbox is the only option.  A version 2
# config would have already been set in the above provider section.
Vagrant::VERSION < "1.1.0" and Vagrant::Config.run do |config|
  config.vm.provision :shell, :inline => $vbox_script
end

# Setup port forwarding per loaded environment variables
forward_ports = FORWARD_DOCKER_PORTS.nil? ? [] : [*49153..49900]
forward_ports += FORWARD_PORTS.split(',').map{|i| i.to_i } if FORWARD_PORTS
if forward_ports.any?
  Vagrant::VERSION < "1.1.0" and Vagrant::Config.run do |config|
    forward_ports.each do |port|
      config.vm.forward_port port, port
    end
  end

  Vagrant::VERSION >= "1.1.0" and Vagrant.configure("2") do |config|
    forward_ports.each do |port|
      config.vm.network :forwarded_port, :host => port, :guest => port, auto_correct: true
    end
  end
end

if !PRIVATE_NETWORK.nil?
  Vagrant::VERSION < "1.1.0" and Vagrant::Config.run do |config|
    config.vm.network :hostonly, PRIVATE_NETWORK
  end

  Vagrant::VERSION >= "1.1.0" and Vagrant.configure("2") do |config|
    config.vm.network "private_network", ip: PRIVATE_NETWORK
  end
end

