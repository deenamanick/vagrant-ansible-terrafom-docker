Vagrant.configure("2") do |config|
  config.vm.box = "bento/ubuntu-22.04"
  config.vm.hostname = "devops-lab"
  config.vm.network "private_network", ip: "192.168.56.10"
  config.vm.network "forwarded_port", guest: 80, host: 8080, auto_correct: true
  config.ssh.insert_key = false
  config.ssh.private_key_path = "~/.vagrant.d/insecure_private_key"

  # Sync Terraform project & app code
  config.vm.synced_folder "./terraform-docker", "/home/vagrant/terraform-docker"
  config.vm.synced_folder "./k8s-quiz", "/home/vagrant/terraform-docker/k8s-quiz"

  # # Set up passwordless SSH for vagrant user
  # config.vm.provision "shell", inline: <<-SHELL
  #   mkdir -p /home/vagrant/.ssh
  #   echo "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2pFmXnbY3Wf9JOLTT5rx1HqGTYNudERe7N3+hxgzm0xx+3e8G6N4Udk+bwJ5/AT5Q9D2jOY2buYJNoy0t9J9EJLZafCO6wScKj0f5EYv7N9q/8tL/dYI1M1XJhD6uJq5d9jH3e+SZk9c2K6PvM3pITp+TjvOjgkAVCk1NC+8ew==" >> /home/vagrant/.ssh/authorized_keys
  #   chmod 600 /home/vagrant/.ssh/authorized_keys
  #   chown -R vagrant:vagrant /home/vagrant/.ssh
  # SHELL

  # Create GitHub Actions workflow file
  config.vm.provision "shell", inline: <<-SHELL
    mkdir -p /home/vagrant/.github/workflows
    chown -R vagrant:vagrant /home/vagrant/.github

    cat <<'EOF' > /home/vagrant/.github/workflows/deploy.yml
name: CI/CD for Quiz App

on:
  push:
    branches:
      - main

jobs:
  build-and-deploy:
    runs-on: self-hosted

    steps:
      - name: Checkout repo
        uses: actions/checkout@v4

      - name: Init Terraform
        working-directory: terraform-docker
        run: terraform init

      - name: Validate Terraform
        working-directory: terraform-docker
        run: terraform validate

      - name: Run Terraform apply
        working-directory: terraform-docker
        run: terraform apply -auto-approve
EOF
  SHELL

  # Provisioners
  config.vm.provision "shell", path: "provision/install_ansible.sh"
  config.vm.provision "shell", path: "provision/install_docker.sh"  
  config.vm.provision "shell", path: "provision/install_terraform.sh"
end
