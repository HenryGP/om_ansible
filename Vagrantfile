# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  
  config.vm.define "opsmgr" do |opsmgr|
    opsmgr.vm.box = "centos/7"
    opsmgr.vm.hostname = 'omserver'

    opsmgr.vm.network :private_network, ip: "192.168.1.100"
    opsmgr.vm.synced_folder 'shared/',"/home/vagrant/shared", create: true

    opsmgr.vm.network :forwarded_port, guest: 22, host: 33333

    opsmgr.vm.provider :virtualbox do |v|
      v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
      v.customize ["modifyvm", :id, "--memory", 4096]
      v.customize ["modifyvm", :id, "--name", "omserver"]
    end
  end

  config.vm.define "node1" do |node1|
    node1.vm.box = "centos/7"
    node1.vm.hostname = 'n1'

    node1.vm.network :private_network, ip: "192.168.1.101"
    node1.vm.synced_folder 'shared/',"/home/vagrant/shared", create: true

    node1.vm.network :forwarded_port, guest: 22, host: 33334    

    node1.vm.provider :virtualbox do |v|
      v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
      v.customize ["modifyvm", :id, "--memory", 512]
      v.customize ["modifyvm", :id, "--name", "n1"]
    end
  end

  config.vm.define "node2" do |node2|
    node2.vm.box = "centos/7"
    node2.vm.hostname = 'n2'

    node2.vm.network :private_network, ip: "192.168.1.102"
    node2.vm.synced_folder 'shared/',"/home/vagrant/shared", create: true

    node2.vm.network :forwarded_port, guest: 22, host: 33335

    node2.vm.provider :virtualbox do |v|
      v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
      v.customize ["modifyvm", :id, "--memory", 512]
      v.customize ["modifyvm", :id, "--name", "n2"]
    end
  end
	
  config.vm.define "backup" do |backup|
    backup.vm.box = "centos/7"
    backup.vm.hostname = 'bkp'

    backup.vm.network :private_network, ip: "192.168.1.103"
    backup.vm.synced_folder 'shared/',"/home/vagrant/shared", create: true
    
    backup.vm.network :forwarded_port, guest: 22, host: 33336

    backup.vm.provider :virtualbox do |v|
      v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
      v.customize ["modifyvm", :id, "--memory", 1024]
      v.customize ["modifyvm", :id, "--name", "bkp"]
    end
  end

  config.vm.provision "ansible" do |ansible|
      ansible.limit = "all"
      ansible.playbook = "om_ansible.yaml"
  end
=begin
ansible.verbose = "vvv"
=end
end