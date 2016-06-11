#!/bin/bash

if [ -a /home/vagrant/sync/source/puppet.tar.gz ]; then
  cp /home/vagrant/sync/source/puppet.tar.gz /tmp
else
  sudo yum install wget -y
  url="https://s3.amazonaws.com/pe-builds/released/2016.1.2/puppet-enterprise-2016.1.2-el-7-x86_64.tar.gz"
  echo "downloading puppet enterprise..."
  wget -O /tmp/puppet.tar.gz "$url"
fi

cp /home/vagrant/sync/scripts/install.answer /tmp

echo 'extracting tarball ...'
tar xvf /tmp/puppet.tar.gz -C /tmp

# Firewall rules
# ADD 8140 443 61613 8142
fw_state=$(systemctl is-enabled firewalld)

if [ "$fw_state" = "disabled" ]; then
  sudo systemctl enable firewalld
  sudo systemctl start firewalld
else
  echo "firewalld service is already $fw_state."
fi

echo "adding firewall rules ..."
firewall-cmd --zone=public --add-port=3000/tcp --permanent
firewall-cmd --zone=public --add-port=8140/tcp --permanent
firewall-cmd --zone=public --add-port=443/tcp --permanent
firewall-cmd --zone=public --add-port=61613/tcp --permanent
firewall-cmd --zone=public --add-port=8142/tcp --permanent
firewall-cmd --reload

# Add master to hosts file for installation
echo "updating /etc/hosts ..."
echo "192.168.250.110 pe-puppet.example.com" >> /etc/hosts

# Install w/answer file
echo "installing puppet enterprise with answer file ..."
sudo /tmp/puppet-enterprise-2016.1.2-el-7-x86_64/puppet-enterprise-installer -a /tmp/install.answer
echo "installing hiera-eyaml ..."
sudo /opt/puppetlabs/puppet/bin/gem install hiera-eyaml
sudo /opt/puppetlabs/bin/puppetserver gem install hiera-eyaml
if [ -a /etc/puppetlabs/puppet/puppet.conf ]; then
  echo "cleaning up ..."
  sudo rm -rf /tmp/*
  echo "https://192.168.250.110 : pw => 'puppetlabs'"
else
  echo "Puppet may not be installed properly ..."
fi