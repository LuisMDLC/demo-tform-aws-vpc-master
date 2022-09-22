

/* Create aws_ami filter to pick up the ami available in your region
data "aws_ami" "amazon-linux-2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
} */

// Configure the EC2 instance in a public subnet
resource "aws_instance" "ec2_public" {
  ami = "ami-065deacbcaac64cf2"
  #ami                         = data.aws_ami.amazon-linux-2.id
  associate_public_ip_address = true
  instance_type               = "t2.micro"
  key_name                    = var.key_name
  subnet_id                   = var.vpc.public_subnets[0]
  vpc_security_group_ids      = [var.sg_pub_id]

user_data = <<-EOL

#!/bin/bash
sed 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/g' /etc/ssh/sshd_config

EOL



  tags = {
    "Name" = "${var.namespace}-EC2-PUBLICA"
  }


  # Copies the ssh key file to home dir

 #provisioner "file" {
  
  #  source      = "./sshd_config"
   # destination = "/etc/ssh/sshd_config"
 

  provisioner "file" {

    source      = "./${var.key_name}.pem"
    destination = "/home/ubuntu/${var.key_name}.pem"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("${var.key_name}.pem")
      host        = self.public_ip
    }
  }
 
  //chmod key 400 on EC2 instance
  provisioner "remote-exec" {
    inline = ["chmod 400 ~/${var.key_name}.pem"]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("${var.key_name}.pem")
      host        = self.public_ip
    }

  }


}


// Configure the EC2 instance in a private subnet
resource "aws_instance" "ec2_private" {
  ami = "ami-065deacbcaac64cf2"
  #ami                         = data.aws_ami.amazon-linux-2.id
  associate_public_ip_address = false
  instance_type               = "t2.micro"
  key_name                    = var.key_name
  subnet_id                   = var.vpc.private_subnets[1]
  vpc_security_group_ids      = [var.sg_priv_id]

  tags = {
    "Name" = "${var.namespace}-EC2-PRIVADA"
  }

provisioner "remote-exec" {
inline = [
# Mounting Efs 
"sudo mount -t nfs -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport ${aws_efs_file_system.efs.dns_name}:/  /var/www/html",
# Making Mount Permanent
"echo ${aws_efs_file_system.efs.dns_name}:/ /var/www/html nfs4 defaults,_netdev 0 0  | sudo cat >> /etc/fstab " ,
"sudo chmod go+rw /var/www/html",
"sudo git clone https://github.com/Apeksh742/EC2_instance_with_terraform.git /var/www/html",
  ]
 }

}


//EFS

resource "aws_efs_file_system" "efs" {
   creation_token = "efs"
   performance_mode = "generalPurpose"
   throughput_mode = "bursting"
   encrypted = "true"
 tags = {
     Name = "EFS"
   }
 }


resource "aws_efs_mount_target" "efs-mt" {
   #count = length(data.aws_availability_zones.available.names)
   file_system_id  = aws_efs_file_system.efs.id
   subnet_id                   = var.vpc.private_subnets[1]
   #vpc_security_group_ids      = [var.sg_priv_id]
 }

 resource "aws_efs_access_point" "efs-ap" {
  file_system_id = aws_efs_file_system.efs.id
}