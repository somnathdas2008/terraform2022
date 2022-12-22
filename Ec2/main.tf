provider "aws" {
  region = "us-east-1"
}
resource "aws_security_group" "morning-ssh-http" {
  name        = "morning-ssh-http"
  description = "allow ssh and http traffic"

  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}
resource "aws_instance" "good-morning" {
  ami               = "ami-064d05b4fe8515623"
  instance_type     = "t2.micro"
  key_name = "testwindows"
  availability_zone = "us-east-1a"
  security_groups   = ["${aws_security_group.morning-ssh-http.name}"]
  user_data = <<-EOF
                #! /bin/bash
                sudo yum install httpd -y
                sudo systemctl start httpd
                sudo systemctl enable httpd
                echo "<h1>Sample Webserver Network Nuts" | sudo tee  /home/573855.cloudwaysapps.com/hfjzxghgzg/public_html/html/index.html
  EOF


  tags = {
        Name = "webserver"
  }

}
#creating and attaching ebs volume

resource "aws_ebs_volume" "data-vol" {
 availability_zone = "us-east-1a"
 size = 1
 tags = {
        Name = "data-volume"
        }
}
resource "aws_volume_attachment" "good-morning-vol" {
 device_name = "/dev/sdc"
 volume_id = "${aws_ebs_volume.data-vol.id}"
 instance_id = "${aws_instance.good-morning.id}"
}