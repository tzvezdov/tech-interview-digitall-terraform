# ## Data source for availability zones
# data "aws_elb_service_account" "main" {}
# data "aws_availability_zones" "available" {
#   state = "available"
# }

# ## VPC
# resource "aws_vpc" "tech-interview-vpc" {
#   cidr_block           = "10.0.0.0/16" # Fixed: was /16 but started at .1
#   enable_dns_hostnames = true
#   enable_dns_support   = true

#   tags = {
#     Name = "tech-interview-vpc"
#   }
# }

# ## Internet Gateway (required for public ALB)
# resource "aws_internet_gateway" "main" {
#   vpc_id = aws_vpc.tech-interview-vpc.id

#   tags = {
#     Name = "main-igw"
#   }
# }

# ## Public Subnets (ALB requires at least 2 in different AZs)
# resource "aws_subnet" "public" {
#   count                   = 2
#   vpc_id                  = aws_vpc.tech-interview-vpc.id
#   cidr_block              = "10.0.${count.index + 1}.0/24" # Resuklts in 10.0.1.0/24 and 10.0.2.0/24
#   availability_zone       = data.aws_availability_zones.available.names[count.index]
#   map_public_ip_on_launch = true

#   tags = {
#     Name = "public-subnet-${count.index + 1}"
#   }
# }

# ## Route Table for public subnets
# resource "aws_route_table" "public" {
#   vpc_id = aws_vpc.tech-interview-vpc.id

#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = aws_internet_gateway.main.id
#   }

#   tags = {
#     Name = "public-rt"
#   }
# }

# ## Route Table Association
# resource "aws_route_table_association" "public" {
#   count          = 2
#   subnet_id      = aws_subnet.public[count.index].id
#   route_table_id = aws_route_table.public.id
# }

# ## Security Group for ALB
# resource "aws_security_group" "lb_sg" {
#   name        = "alb-security-group"
#   description = "Security group for Application Load Balancer"
#   vpc_id      = aws_vpc.tech-interview-vpc.id

#   # HTTP access for testing
#   ingress {
#     description = "HTTP from anywhere"
#     from_port   = 80
#     to_port     = 80
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   # Outbound to targets
#   egress {
#     description = "Allow all outbound"
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     Name = "alb-sg"
#   }
# }

# ## S3 Bucket for ELB logs
# resource "aws_s3_bucket" "lb_logs" {
#   bucket = "lblogsrandom" # Change to globally unique name

#   tags = {
#     Name = "ALB Logs Bucket"
#   }
# }

# ## S3 Bucket Policy (required for ALB to write logs)
# resource "aws_s3_bucket_policy" "lb_logs" {
#   bucket = aws_s3_bucket.lb_logs.id

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Principal = {
#           AWS = data.aws_elb_service_account.main.arn
#         }
#         Action   = "s3:PutObject"
#         Resource = "${aws_s3_bucket.lb_logs.arn}/test-lb/AWSLogs/*"
#       }
#     ]
#   })
# }

# ## Application Load Balancer
# resource "aws_lb" "test" {
#   name               = "test-lb-tf"
#   internal           = false
#   load_balancer_type = "application"
#   security_groups    = [aws_security_group.lb_sg.id]
#   subnets            = [for subnet in aws_subnet.public : subnet.id]

#   enable_deletion_protection = true

#   access_logs {
#     bucket  = aws_s3_bucket.lb_logs.id
#     prefix  = "test-lb"
#     enabled = true
#   }

#   tags = {
#     Environment = "production"
#   }
# }

# ## Target Group (where ALB forwards traffic)
# resource "aws_lb_target_group" "main" {
#   name     = "main-target-group"
#   port     = 80
#   protocol = "HTTP"
#   vpc_id   = aws_vpc.tech-interview-vpc.id

#   health_check {
#     enabled             = true
#     healthy_threshold   = 2
#     interval            = 30
#     matcher             = "200"
#     path                = "/"
#     port                = "traffic-port"
#     protocol            = "HTTP"
#     timeout             = 5
#     unhealthy_threshold = 2
#   }

#   tags = {
#     Name = "main-tg"
#   }
# }

# ## HTTP Listener (port 80) - for testing
# resource "aws_lb_listener" "http" {
#   load_balancer_arn = aws_lb.test.arn
#   port              = 80
#   protocol          = "HTTP"

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.main.arn
#   }

# }

# ## Outputs - could be sent to a file outputs.tf for example
# output "alb_dns_name" {
#   description = "DNS name of the load balancer"
#   value       = aws_lb.test.dns_name
# }
