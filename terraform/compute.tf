resource "aws_instance" "test" {
  ami           = "ami-08eb150f611ca277f" # Amazon Linux 2023 in eu-north-1
  instance_type = "t3.micro"

  tags = {
    Name = "terraform-test-instance"
  }
}
