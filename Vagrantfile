# In your Vagrantfile, replace the entire content with:

Vagrant.configure("2") do |config|
  config.vm.box = "bento/ubuntu-22.04"
  config.vm.hostname = "devops-lab"
  config.vm.network "private_network", ip: "192.168.56.10"
  config.ssh.insert_key = false
  config.ssh.private_key_path = "~/.vagrant.d/insecure_private_key"

  # Sync the current directory to /vagrant
  config.vm.synced_folder ".", "/vagrant"

  # Install Docker
  config.vm.provision "docker", type: "shell", inline: <<-SHELL
    # Install Docker
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    usermod -aG docker vagrant
    systemctl enable --now docker
  SHELL

  # Start self-hosted runner in Docker
  config.vm.provision "runner", type: "shell", path: "provision/setup_runner_container.sh", run: "always"
end