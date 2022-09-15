resource "aws_key_pair" "poc" {
  key_name   = "mac-ssh-key"
  public_key = file(var.KEY_PATH)
}

resource "aws_instance" "master" {
  ami                    = var.AMIS[var.AWS_REGION]
  instance_type          = var.INSTANCE_TYPE
  key_name               = aws_key_pair.poc.key_name
  vpc_security_group_ids = [aws_security_group.master.id]
  subnet_id              = aws_subnet.poc.id
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name
  user_data_base64       = base64encode(data.cloudinit_config.master.rendered)

  tags = {
    "Name" = "Master"
  }
}

resource "aws_instance" "agent" {
  count                  = 2
  ami                    = var.AMIS[var.AWS_REGION]
  instance_type          = var.INSTANCE_TYPE
  key_name               = aws_key_pair.poc.key_name
  vpc_security_group_ids = [aws_security_group.agent.id]
  subnet_id              = aws_subnet.poc.id
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name
  user_data_base64       = base64encode(data.cloudinit_config.agent.rendered)

  tags = {
    "Name" = "Agent${count.index + 1}"
  }
}

data "cloudinit_config" "master" {
  gzip          = false
  base64_encode = false

  part {
    content_type = "text/x-shellscript"
    content      = templatefile("scripts/master_setup.sh", {})
  }

  part {
    content_type = "text/x-shellscript"
    content = templatefile("scripts/mount_s3.sh", {
      IAM_ROLE_NAME = var.IAM_ROLE_NAME,
      BUCKET_NAME = var.BUCKET_NAME
    })
  }
}

data "cloudinit_config" "agent" {
  gzip          = false
  base64_encode = false

  part {
    content_type = "text/x-shellscript"
    content      = templatefile("scripts/agent_setup.sh", {})
  }

  part {
    content_type = "text/x-shellscript"
    content = templatefile("scripts/mount_s3.sh", {
      IAM_ROLE_NAME = var.IAM_ROLE_NAME,
      BUCKET_NAME = var.BUCKET_NAME
    })
  }
}

resource "aws_s3_bucket" "poc" {
  bucket = var.BUCKET_NAME

  tags = { for k, v in var.TAGS : k => lower(v) }
}


resource "aws_iam_role" "ec2_role" {
  name = var.IAM_ROLE_NAME
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = { for k, v in var.TAGS : k => lower(v) }
}

resource "aws_iam_policy" "s3_policy" {
  name = "s3_policy"
  path = "/"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:*",
          "s3-object-lambda:*"
        ],
        "Resource" : "*"
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "poc" {
  name       = "ec2-attachment"
  roles      = [aws_iam_role.ec2_role.name]
  policy_arn = aws_iam_policy.s3_policy.arn
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2_profile"
  role = aws_iam_role.ec2_role.name
}