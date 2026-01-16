# ## Security Group for EC2 instances
# resource "aws_security_group" "ec2_sg" {
#   name        = "ec2-security-group"
#   description = "Security group for EC2 instances behind ALB"
#   vpc_id      = aws_vpc.tech-interview-vpc.id

#   # Only allow traffic from the ALB
#   ingress {
#     description     = "HTTP from ALB"
#     from_port       = 80
#     to_port         = 80
#     protocol        = "tcp"
#     security_groups = [aws_security_group.lb_sg.id]
#   }

#   # SSH access (optional - for debugging)
#   ingress {
#     description = "SSH"
#     from_port   = 22
#     to_port     = 22
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"] # Restrict to your IP in production
#   }

#   egress {
#     description = "Allow all outbound"
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     Name = "ec2-sg"
#   }
# }

# ## Get latest Amazon Linux 2 AMI
# data "aws_ami" "amazon_linux" {
#   most_recent = true
#   owners      = ["amazon"]

#   filter {
#     name   = "name"
#     values = ["amzn2-ami-hvm-*-x86_64-gp2"]
#   }
# }

# ## EC2 Instance
# resource "aws_instance" "web" {
#   ami                         = data.aws_ami.amazon_linux.id
#   instance_type               = "t3.micro"
#   subnet_id                   = aws_subnet.public[0].id
#   vpc_security_group_ids      = [aws_security_group.ec2_sg.id]
#   associate_public_ip_address = true

#   # Simple web server for testing
#   user_data = <<-EOF
#               #!/bin/bash
#               yum update -y
#               yum install -y httpd
#               systemctl start httpd
#               systemctl enable httpd
#               echo "<h1>Hello from $(hostname -f)</h1>" > /var/www/html/index.html
#               EOF

#   tags = {
#     Name = "web-server"
#   }
# }

# ## Attach EC2 to Target Group
# resource "aws_lb_target_group_attachment" "web" {
#   target_group_arn = aws_lb_target_group.main.arn
#   target_id        = aws_instance.web.id
#   port             = 80
# }

# ## Outputs

# output "ec2_public_ip" {
#   description = "Public IP of the EC2 instance"
#   value       = aws_instance.web.public_ip
# }
