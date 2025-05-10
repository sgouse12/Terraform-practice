resource "aws_vpc" "myvpc" {
  cidr_block       = var.cidr_block


  tags = {
    Name = "vpc"
  }
}


resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.myvpc.id
  cidr_block = "10.0.0.0/24"
  availability_zone = "ap-south-1a"
  tags = {
    Name = "public"
  }

}

 resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.myvpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "ap-south-1a"
  tags = {
    Name = "private"
  }

}
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.myvpc.id

  tags = {
    Name = "igw"
  }
}


resource "aws_eip" "ngw" {
  tags = {
    name = "ngw_ip"
  }
}

resource "aws_nat_gateway" "NAT" {
  allocation_id = aws_eip.ngw.id
  subnet_id     = aws_subnet.public.id

  tags = {
    Name = "gw NAT"
  }
}
resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "rt1" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.rt.id
}

resource "aws_route_table_association" "rt2" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.rt.id
}

resource "aws_security_group" "sg" {
  name        = "sg"
  description = "sg "
  vpc_id      = aws_vpc.myvpc.id


  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

   ingress {
    description = "HTTP from VPC"
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

  tags = {
    Name = "sg"
  }
}


resource "aws_instance" "web1" {
  ami                    = data.aws_ami.ami.id
  count                  = 2
  instance_type          = "t3.micro"
  availability_zone      = "ap-south-1a"
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.sg.id]
}
