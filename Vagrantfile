# -*- mode: ruby -*-
# vi: set ft=ruby :

# configs
#$box_os = "ubuntu/trusty64"
$box_os = "centos/7"
$ipaddress = "192.168.250.110"
$box_provider = :virtualbox

Vagrant.configure(2) do |config|
  config.vm.box = $box_os
  config.vm.provider $box_provider do |vb|
    vb.customize ["modifyvm", :id, "--natdnsproxy1", "off"]
    vb.customize ["modifyvm", :id, "--natdnshostresolver1", "off"]
    vb.memory = "4096"
  end

# box
  config.vm.define "puppet", primary: true do |puppet|
    #puppet.vm.synced_folder "scripts/", "/tmp"
    puppet.vm.hostname = "pe-puppet.example.com"
    puppet.vm.network :private_network, ip: $ipaddress
    puppet.vm.provision :shell, path: "scripts/bootstrap-el.sh"
  end

end
