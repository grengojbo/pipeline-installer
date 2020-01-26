provider "aws" {
  version = "~> 2.40"

  region = lookup(var.config, "region", "us-west-1")

  # Workaround for eager provider initialization if it is not used it requires some credentials, lets give it:
  access_key                  = var.enabled == true ? "" : "bla"
  secret_key                  = var.enabled == true ? "" : "bla"
  skip_credentials_validation = ! var.enabled
  skip_requesting_account_id  = ! var.enabled
  skip_region_validation      = ! var.enabled
}

provider "local" {
  version = "~> 1.4"
}

provider "null" {
  version = "~> 2.1"
}

provider "tls" {
  version = "~> 2.1"
}

data "aws_ami" "banzaicloud-centos" {
  count       = var.enabled == true ? 1 : 0
  most_recent = true

  //pke version 0.4.17 , k8s version: 1.16.1
  filter {
    name   = "name"
    values = ["centos-7-pke-201910151531"]
  }

  //  filter {
  //    name   = "tag:company"
  //    values = ["banzaicloud"]
  //  }
  //
  //  filter {
  //    name   = "tag:Name"
  //    values = ["centos-7-base"]
  //  }

  owners = ["161831738826"] # Banzaicloud
}

data "aws_availability_zones" "available_az" {
  count = var.enabled == true ? 1 : 0
  state = "available"
}

data "aws_vpc" "selected" {
  count   = var.enabled == true ? 1 : 0
  id      = lookup(var.config, "vpc_id", "")
  default = lookup(var.config, "vpc_id", "") == "" ? true : false
}

data "aws_subnet" "selected" {
  count             = var.enabled == true ? 1 : 0
  id                = lookup(var.config, "subnet_id", "")
  vpc_id            = data.aws_vpc.selected[0].id
  availability_zone = lookup(var.config, "subnet_id", "") == "" ? data.aws_availability_zones.available_az[0].names[0] : ""
}

resource "aws_security_group" "security-group" {
  count  = var.enabled == true ? 1 : 0
  vpc_id = data.aws_vpc.selected[0].id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH access"
  }

  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "PKE Api Server Address"
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Pipeline HTTP"
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Pipeline HTTPS"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    { Name = "Banzai Cloud Pipeline" },
    lookup(var.config, "tags", {})
  )
}

data "local_file" "user_data" {
  count    = var.enabled == true ? 1 : 0
  filename = "${path.module}/user-data.sh"
}

resource "tls_private_key" "pipeline" {
  count     = var.enabled == true ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  //key_name   = "pipeline"
  count      = var.enabled == true ? 1 : 0
  public_key = tls_private_key.pipeline[0].public_key_openssh
}

resource "aws_instance" "pipeline" {
  count = var.enabled == true ? 1 : 0

  ami      = lookup(var.config, "ami", data.aws_ami.banzaicloud-centos[0].id)
  key_name = lookup(var.config, "key_name", aws_key_pair.generated_key[0].key_name)

  instance_type               = lookup(var.config, "instance_type", "c5.large")
  vpc_security_group_ids      = [aws_security_group.security-group[0].id]
  associate_public_ip_address = lookup(var.config, "associate_public_ip_address", true)

  subnet_id = data.aws_subnet.selected[0].id

  user_data = data.local_file.user_data[0].content

  root_block_device {
    volume_type           = "gp2"
    volume_size           = "100"
    delete_on_termination = "true"
  }

  tags = merge(
    { Name = "Banzai Cloud Pipeline" },
    lookup(var.config, "tags", {})
  )
}

resource "null_resource" "shell" {
  count = var.enabled == true ? 1 : 0

  triggers = {
    instance_id = aws_instance.pipeline[0].id
  }

  connection {
    type        = "ssh"
    host        = aws_instance.pipeline[0].public_ip
    user        = "centos"
    private_key = tls_private_key.pipeline[0].private_key_pem
  }

  provisioner "file" {
    source      = "${path.module}/wait.sh"
    destination = "/tmp/wait.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/wait.sh",
      "sudo /tmp/wait.sh",
    ]
  }
}
