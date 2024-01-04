variable "bastion-instance-type" {
  default = "t2.micro"
}

variable "webserver-instance-type" {
  default = "t2.medium"
}

variable "container-port" {
  default = 3000
}

variable "host-port" {
  default = 3000
}

variable "cluster_name" {
  default = "hackathon-ecs-cluster"
}
