# Update base system
apt-get update -y
apt-get install -y python3-pip curl gnupg lsb-release apt-transport-https ca-certificates software-properties-common

    # Install Docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
  > /etc/apt/sources.list.d/docker.list
apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io
systemctl enable docker
systemctl start docker
usermod -aG docker vagrant


chown -R vagrant:vagrant /home/vagrant/terraform-docker

    # Setup Docker workers
# docker network create --subnet=172.20.0.0/24 ansible-net || true
# docker pull ubuntu:22.04
# for i in 1 2; do
#       cname="worker$i"
#       cip="172.20.0.1$i"
#       docker rm -f $cname || true
#       docker run -d --name $cname --hostname $cname \
#         --net ansible-net --ip $cip \
#         --privileged ubuntu:22.04 sleep infinity
#       docker exec $cname apt-get update
#       docker exec $cname apt-get install -y openssh-server python3 sudo
#       docker exec $cname mkdir -p /var/run/sshd /root/.ssh
#       docker exec $cname bash -c "echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config"
#       docker exec $cname service ssh start
#       pubkey=$(cat /home/vagrant/.ssh/id_rsa.pub)
#       docker exec $cname bash -c "echo '${pubkey}' >> /root/.ssh/authorized_keys"
# done

# Setup Docker workers
docker network create --subnet=172.20.0.0/24 ansible-net || true
docker pull ubuntu:22.04

pubkey=$(cat /home/vagrant/.ssh/id_rsa.pub)

for i in 1 2; do
  cname="worker$i"
  cip="172.20.0.1$i"

  docker rm -f $cname || true
  docker run -d --name $cname --hostname $cname \
    --net ansible-net --ip $cip \
    --privileged ubuntu:22.04 sleep infinity

  docker exec $cname apt-get update
  docker exec $cname apt-get install -y openssh-server python3 sudo

  docker exec $cname mkdir -p /var/run/sshd /root/.ssh
  docker exec $cname bash -c "echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config"

  # Add the VM's pubkey into root's authorized_keys safely
 # echo "$pubkey" | docker exec -i $cname tee /root/.ssh/authorized_keys > /dev/null
  echo "$pubkey"| docker exec -i $cname bash -c 'tee /root/.ssh/authorized_keys' > /dev/null

  # Fix SSH perms
  docker exec $cname chmod 700 /root/.ssh
  docker exec $cname chmod 600 /root/.ssh/authorized_keys

  # Restart ssh service
  docker exec $cname service ssh restart
done
