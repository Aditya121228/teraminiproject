#1.create VPC

resource "aws_vpc" "myfirstvpc"{
  cidr_block = "40.0.0.0/16"
  tags = {
    Name = "production"
  }
}

#2. create Internet gateway

resource "aws_internet_gateway" "mygw" {
  vpc_id = aws_vpc.myfirstvpc.id
}

#3. create Route Table
resource "aws_route_table" "prod-route-table" {
  vpc_id = aws_vpc.myfirstvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.mygw.id
  }

     tags = {
        Name = "publicrttableterraform"
  }
}

#4. Create subnet

resource "aws_subnet" "subnet1"{
  vpc_id = aws_vpc.myfirstvpc.id
  cidr_block = "40.0.1.0/24"
  availability_zone = "ap-south-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "prod_vpc"
  }
}

#5. aws route table subnet association

resource "aws_route_table_association" "prod" {
  subnet_id = aws_subnet.subnet1.id
  route_table_id = aws_route_table.prod-route-table.id  
}

#6. Create security group

resource "aws_security_group" "terraform-sg" {
  name        = "terraform-sg"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.myfirstvpc.id

  ingress {
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allowhttpsssh"
  }
}

 # 7. create network interface 

resource "aws_network_interface" "test" {
  subnet_id       = aws_subnet.subnet1.id
  private_ips     = ["40.0.1.50"]
  security_groups = [aws_security_group.terraform-sg.id]

}

#9. creating server

resource "aws_instance" "terraformserver"{
  ami = "ami-0b09627181c8d5778"
  instance_type =  "t2.micro"
  availability_zone = "ap-south-1a"
  key_name = "aditya1212"

  network_interface{
    device_index = 0
    network_interface_id = aws_network_interface.test.id

  }
  
  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install httpd -y
              sudo systemctl start httpd
              echo "My web server" >> /var/www/html/index.html
              EOF

  
  tags = {
    Name = "terraformendtoend"
  }

}

