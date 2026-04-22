# -*- mode: ruby -*-
# vi: set ft=ruby :
Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/jammy64"

  # Port forwarding for Docker app (Task 2)
  config.vm.network "forwarded_port", guest: 8000, host: 8000

  # Allow Vagrant to use its own key for management
  config.ssh.insert_key = false
  config.ssh.private_key_path = [
    ".vagrant/machines/default/virtualbox/private_key",  # Vagrant-managed key
    "~/.ssh/devops_vm"                                    # Ed25519 key from Task 1
  ]

  # VirtualBox resource configuration
  config.vm.provider "virtualbox" do |vb|
    vb.memory = "2048"
    vb.cpus = 2
  end
end