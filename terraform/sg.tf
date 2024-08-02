# The bouncer at the door of our TrustWallet service party.
resource "aws_security_group" "trustwallet_sg" {
  name        = "trustwallet-security-group"
  description = "Security group for TrustWallet service"
  vpc_id      = data.aws_vpc.vpc_dev.id
  
  ingress {
    description      = "Allow inbound traffic on port 8080"
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"] # WARNING - Assumed as a public service
  }

  ingress {
    description      = "Allow inbound traffic on port 80"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"] # WARNING - Assumed as a public service
  }

  # Allowing our TrustWallet to speak freely to the outside world.
  egress {
    description      = "Public Outbound Traffic"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "trustwallet-security-group"
  }
}

# SG Output
output "trustwallet_sg_id" {
  value = aws_security_group.trustwallet_sg.id
}
