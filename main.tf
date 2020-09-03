# 1. Configure the AWS Provider
provider "aws" {
  region  = "ap-south-1"
  #access_key = "my-access-key"
  #secret_key = "my-secret-key"
}
#2. Create the VPC
resource "aws_vpc" "WAVPC"{
    cidr_block  = "10.0.0.0/16"
    enable_dns_hostnames = "true"
        tags = {
        Name = "WAVPC"
        }
}
#3. Create the internet gateway
resource "aws_internet_gateway" "WAIGW" {
    vpc_id = aws_vpc.WAVPC.id
        tags = {
            Name = "WAIGW"
        } 
}
#3.1 Create the NAT gateway
resource "aws_nat_gateway" "WANGW" {
    subnet_id = aws_subnet.WAPUSN.id
    allocation_id = aws_eip.EIP.id
        tags = {
            Name = "WANGW"
        }
}
#3.2 Create the Elastic IP
resource "aws_eip" "EIP" {
  #instance = "${aws_instance.web.id}"
  vpc      = true
  depends_on = [aws_internet_gateway.WAIGW]
    tags = {
        Name = "NAT Elastic IP"
    }
}
#3.3
#4. Create the Route Table
resource "aws_route_table" "WART1" {
  vpc_id = aws_vpc.WAVPC.id

  route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.WAIGW.id
   }
   tags = {
       Name = "WART1"
   }
} 
#4.1 Create the private Route table
resource "aws_route_table" "WART2" {
  vpc_id = aws_vpc.WAVPC.id

  route {
      cidr_block = "0.0.0.0/0"
      nat_gateway_id = aws_nat_gateway.WANGW.id
   }
   tags = {
       Name = "WART2"
   }
} 

#5. Create the Subnet
resource "aws_subnet" "WAPTSN" {
    vpc_id = aws_vpc.WAVPC.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "ap-south-1a"
    tags = {
            Name = "WAPTSN"
        }
} 
resource "aws_subnet" "WAPUSN" {
    vpc_id = aws_vpc.WAVPC.id
    cidr_block = "10.0.2.0/24"
    availability_zone = "ap-south-1b"
        tags = {
            Name = "WAPUSN"
        }
} 
resource "aws_subnet" "WAPTSN1" {
    vpc_id = aws_vpc.WAVPC.id
    cidr_block = "10.0.3.0/24"
    availability_zone = "ap-south-1c"
        tags = {
            Name = "WAPTSN1"
        }
} 

#6. Associate the subnets into Route Tables
resource "aws_route_table_association" "WAASRT1" {
  subnet_id      = aws_subnet.WAPUSN.id
  route_table_id = aws_route_table.WART1.id
}
# resource "aws_route_table_association" "WAASRT2" {
#   subnet_id      = aws_subnet.WAPUSN.id
#   route_table_id = aws_route_table.WART1.id
# }
resource "aws_route_table_association" "WAASRT2" {
  subnet_id      = aws_subnet.WAPTSN.id 
  route_table_id = aws_route_table.WART2.id
}
resource "aws_route_table_association" "WAASRT3" {
  subnet_id      = aws_subnet.WAPTSN1.id 
  route_table_id = aws_route_table.WART2.id
}
#7 Create the Security Groups

resource "aws_security_group" "WASG1" {
  name        = "WASG1"
  description = "WebApplication Security Group 1"
  vpc_id      = aws_vpc.WAVPC.id

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Allow_WebApplication_Access"
  }
}
#7.1 Create the Security Groups

resource "aws_security_group" "WARDSSG1" {
  name        = "WARDSSG1"
  description = "Database Security Group 1"
  vpc_id      = aws_vpc.WAVPC.id

  ingress {
    description = "Mysql"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["10.0.2.0/24"]
  }
#   ingress {
#     description = "HTTP"
#     from_port   = 80
#     to_port     = 80
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#   ingress {
#     description = "SSH"
#     from_port   = 22
#     to_port     = 22
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Allow_DataBase_Access"
  }
}
#Create the NACLs for Public
resource "aws_network_acl" "public-subnet-NACL" {
  vpc_id = aws_vpc.WAVPC.id
  subnet_ids = [aws_subnet.WAPUSN.id]
  
  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }
  egress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }
    egress {
    protocol   = "tcp"
    rule_no    = 300
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 22
    to_port    = 22
  }
    egress {
    protocol   = "tcp"
    rule_no    = 400
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 3306
    to_port    = 3306
  }
    egress {
    protocol   = "tcp"
    rule_no    = 500
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }
  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }
  ingress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }
    ingress {
    protocol   = "tcp"
    rule_no    = 300
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 22
    to_port    = 22
  }
  ingress {
    protocol   = "tcp"
    rule_no    = 500
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }
  tags = {
    Name = "public-subnet-NACL"
  }
}
#Create the NACLs for Public
resource "aws_network_acl" "private-subnet-NACL" {
  vpc_id = aws_vpc.WAVPC.id
  subnet_ids = [aws_subnet.WAPTSN.id , aws_subnet.WAPTSN1.id]
    
  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }
  egress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }
#     egress {
#     protocol   = "tcp"
#     rule_no    = 300
#     action     = "allow"
#     cidr_block = "0.0.0.0/0"
#     from_port  = 22
#     to_port    = 22
#   }
#     egress {
#     protocol   = "tcp"
#     rule_no    = 400
#     action     = "allow"
#     cidr_block = "0.0.0.0/0"
#     from_port  = 3306
#     to_port    = 3306
#   }
    egress {
    protocol   = "tcp"
    rule_no    = 500
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }
  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 3306
    to_port    = 3306
  }
#   ingress {
#     protocol   = "tcp"
#     rule_no    = 200
#     action     = "allow"
#     cidr_block = "0.0.0.0/0"
#     from_port  = 443
#     to_port    = 443
#   }
    ingress {
    protocol   = "tcp"
    rule_no    = 300
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 22
    to_port    = 22
  }
  ingress {
    protocol   = "tcp"
    rule_no    = 500
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }
  tags = {
    Name = "private-subnet-NACL"
  }
}
# Create AWS network interface
resource "aws_network_interface" "WASNIC" {
  subnet_id       = aws_subnet.WAPUSN.id
  private_ips     = ["10.0.2.50"]
  security_groups = [aws_security_group.WASG1.id]

#   attachment {
#     instance     = "${aws_instance.test.id}"
#     device_index = 1
#   }
}
#Allocate Eslatic IP
resource "aws_eip" "WAEIP" {
  #instance = "${aws_instance.web.id}"
  vpc      = true
  network_interface = aws_network_interface.WASNIC.id
  associate_with_private_ip = "10.0.2.50" 
  depends_on = [aws_internet_gateway.WAIGW]
}
#Create the Instance and install the apache
resource "aws_instance" "Myec2" {
    ami = "ami-0732b62d310b80e97"
    instance_type = "t2.micro"
    availability_zone = "ap-south-1b"
    key_name = "Myvmkey"
    iam_instance_profile = "S3AdminRole"
    network_interface {
        device_index = 0
        network_interface_id = aws_network_interface.WASNIC.id
    }
    user_data = <<-EOF
                #!/bin/bash
                sudo yum update -y
                sudo yum install httpd php php-mysql git -y
                sudo systemctl start httpd
                sudo systemctl enable httpd
                #echo "This is WEB APPLICATIONS Home page" > /var/www/html/index.html
                echo "<?php phpinfo();?>" > /var/www/html/index.php
                echo "You Landed in unidentified zone. Sorry try again" > /var/www/html/error.html
                aws s3 cp s3://cloudtech2020/connect.php /var/www/html/
                EOF
    tags = {
        Name = "MyAmazonVM"
    }
}
#DB subnets group for RDS
resource "aws_db_subnet_group" "dbsubnets" {
  name       = "dbsng"
  subnet_ids = ["${aws_subnet.WAPTSN.id}", "${aws_subnet.WAPTSN1.id}"]

  tags = {
    Name = "My DB subnet group"
  }
}
#Create the RDS instance - mysql
resource "aws_db_instance" "mydbrds" {
  identifier           = "wards"  
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t2.micro"
  name                 = "mydb"
  username             = "admin"
  password             = "password"
  parameter_group_name = "default.mysql5.7"
  availability_zone    = "ap-south-1a"
  skip_final_snapshot = "true"
  db_subnet_group_name = aws_db_subnet_group.dbsubnets.name
  vpc_security_group_ids = [aws_security_group.WARDSSG1.id]
}

output Instance_id {
    value = aws_instance.Myec2.id
    }

output Instance_public_ip {
    value = aws_instance.Myec2.public_ip
} 
output DBendpoint {
  value = aws_db_instance.mydbrds.endpoint
}
