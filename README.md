# Welcome To IAC for the Web Application Project

Well, This is 2 tier application using the LAMP stack and automated the environment build using the Infrastructure as Code[IAC] at AWS Cloud.

And this IAC helps to run the WEB server and DB server in an isolated network and in a more restricted way like a production environment. [And still open for the improvements and feedbacks :-) ]

# Here are the resources/tools details used in IAC:

## Tools:

1. AWS Cloud environment
2. Terraform [Insfrasture as Code]
3. Visual Studio Code

## Servers:

1. Operating System - Redhat 7 or CentOS 7
2. Web Server - Apache HTTPD
2. DataBase Server - RDS MYSQL
3. Web Development Scripting Language - PHP

## AWS Resouces:

1. AWS user with admin privilege and keys [access key and secret key]
2. VPC
3. Subnet
4. Route Table
5. IGW
6. NAT
7. NACL
8. Security Group
9. Elastic IP  
10. EC2
11. RDS
12. S3

## Notes to Run the App
[In order to run the code, You should have installed the terraform and AWS Account, IAM user credentials in your Laptop or Desktop]
1. Download the Source
    - git clone <url>
2. Run the terraform commands 
    -   terraform init
    -   terraform plan
    -   terraform apply --auto-approve
    -   terraform destory --auto-approve #if you come across any issue or you're done with testing.
3. Use the connect.php file from assets folder. [Which will help to skip the S3Adminrole assignment and copying connect.php]
4. Update the DB endpoint into webserver location/var/www/html/connect.php
5. Validate the webserver using the EC2 elastic IP address.


# FeedBack: rramesh.rsd@gmail.com


