# -*- mode: ruby -*-
# vi: set ft=ruby :

# NOTE: expects a YAML inventory file with host vars
# (such as IP address, cps or memory) directly beneath the hostname.
# disregards vars elsewhere in the heirarchy
default_ip="10.8.21.100"
default_cpus=2
default_memory=2048
# centos
default_vm_box="centos/7"
default_vm_box_version="1804.02"
# debian
#default_vm_box="debian/stretch64"
#default_vm_box_version="9.2.0"

# NOTE" makes use of the Hashie gem to parse Ansible's YAML inventory files
# install before using like:
# vagrant plugin install hashie

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure(2) do |config|
  # this same file is used for ansible inventory
  inventory_path = 'inventory/vagrant'
  inventory = YAML.load_file(inventory_path)
  inventory.extend Hashie::Extensions::DeepFind
  ansible_hosts = inventory.deep_find_all('hosts').inject(:merge)

  ansible_hosts.each_with_index do |(host_name, host_vars), index|
    # set empty host_vars, if none provided
    if not host_vars
      host_vars = Hash.new
    end

    # increment the default ip in case we need it
    default_ip = default_ip.succ

    config.vm.define host_name do |host|
      # set up box image for each host
      host.vm.box = host_vars['vagrant_box_image'] || default_vm_box
      host.vm.box_version = host_vars['vagrant_box_version'] || default_vm_box_version

      # configure network
      host.vm.network 'private_network', ip: host_vars['ansible_ip'] || default_ip
      host.vm.hostname = host_name

      # presumes installation of https://github.com/cogitatio/vagrant-hostsupdater on host
      if host_vars['aliases']
        host.hostsupdater.aliases = host_vars['aliases']
      end

      # avoiding "Authentication failure" issue
      host.ssh.insert_key = false
      host.vm.synced_folder ".", "/vagrant", disabled: true

      host.vm.provider "virtualbox" do |vb|
        vb.name = host_name
        vb.memory = host_vars['memory'] || default_memory
        vb.cpus = host_vars['cpus'] || default_cpus
        vb.linked_clone = true
      end

      if index == (ansible_hosts.size - 1)
        host.vm.provision "ansible" do |ansible|
          ansible.galaxy_role_file = "requirements.yml"
          ansible.inventory_path = inventory_path
          ansible.playbook = "setup.yml"
          ansible.limit = "all,localhost"
          ansible.verbose = "v"
        end
      end
    end
  end
end
