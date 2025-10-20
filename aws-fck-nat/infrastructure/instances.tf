resource "aws_instance" "fck-nat" {
  count             = length(aws_subnet.public)
  ami               = data.aws_ami.fck-nat.id
  instance_type     = "t3.micro"
  availability_zone = aws_subnet.public[count.index].availability_zone

  root_block_device {
    delete_on_termination = true
    encrypted             = true
    volume_size           = 8
  }

  iam_instance_profile   = aws_iam_instance_profile.fck-nat.name
  subnet_id              = aws_subnet.public[count.index].id
  vpc_security_group_ids = [aws_security_group.fck-nat.id]

  associate_public_ip_address = true
  source_dest_check           = false

  tags = { Name = upper("${var.name_prefix}-fck-NAT") }
}

resource "aws_iam_instance_profile" "fck-nat" {
  name = upper("${var.name_prefix}-fck-NAT")
  role = aws_iam_role.fck-nat.name
}
