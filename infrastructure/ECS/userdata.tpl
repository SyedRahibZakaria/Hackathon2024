#!/bin/bash
sudo su -
sudo yum update -y
sudo amazon-linux-extras install -y docker
sudo systemctl enable docker.service
sudo systemctl start docker.service
sudo usermod -aG docker ec2-user
sudo amazon-linux-extras install -y ecs
sudo cp /usr/lib/systemd/system/ecs.service /etc/systemd/system/ecs.service
sudo sed -i '/After=cloud-final.service/d' /etc/systemd/system/ecs.service
sudo systemctl daemon-reload
sudo systemctl start ecs.service
echo ECS_CLUSTER="${cluster_name}" >> /etc/ecs/ecs.config
