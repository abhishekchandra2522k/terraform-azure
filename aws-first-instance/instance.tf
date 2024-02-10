# #creating ssh key
resource "aws_key_pair" "key-tf" {
  key_name   = "key-tf"
  public_key = file("${path.module}/id_rsa.pub")
}

resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic and all outbound traffic"

  dynamic "ingress" {
    for_each = var.ports
    iterator = port
    content {
      description = "TLS from VPC"
      from_port   = port.value
      to_port     = port.value
      protocol    = "tcp"
      cidr_blocks = ["10.0.0.0/16"]
    }
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

# creating ec2 instance
resource "aws_instance" "web" {
  ami           = var.image_id
  instance_type = var.instance_type

  key_name               = aws_key_pair.key-tf.key_name
  vpc_security_group_ids = ["${aws_security_group.allow_tls.id}"]

  tags = {
    Name = "HelloWorld"
  }
}
