resource "aws_key_pair" "backend_ec2_server_ssh_key" {
  key_name   = "ssh-key"
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_instance" "backend_ec2_server" {
  ami           = "ami-00bb6a80f01f03502"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.backend_ec2_server_ssh_key.key_name
  subnet_id = var.public_subnets_ids[0]
  associate_public_ip_address = true

  iam_instance_profile = aws_iam_instance_profile.backend_ec2_instance_profile.name


  user_data = <<-EOF
                #!/bin/bash
                echo "Hello World" > hello.txt
              EOF

  vpc_security_group_ids = [aws_security_group.allow_ssh_ips.id, aws_security_group.allow_http.id]

  tags = {
    Name = "${var.project_prefix}-backend-ec2-server"
  }
}
resource "aws_ebs_volume" "backend_ec2_volume" {
  availability_zone = aws_instance.backend_ec2_server.availability_zone
  size              = var.ebs_size  # Size in GB
  type              = "gp3"

  tags = {
    Name = "${var.project_prefix}-volume"
  }
}

resource "aws_volume_attachment" "backend_ebs_attachment" {
  device_name = "/dev/xvdf"  # Typical device name for Linux
  volume_id   = aws_ebs_volume.backend_ec2_volume.id
  instance_id = aws_instance.backend_ec2_server.id
}

resource "aws_iam_instance_profile" "backend_ec2_instance_profile" {
  name = "${var.project_prefix}-ec2-instance-profile"
  role = aws_iam_role.backend_app_role.name
}


# ebs volume backup daily
resource "aws_dlm_lifecycle_policy" "ebs_backup_policy" {
  description = "EBS Backup Policy for ${var.project_prefix}-backend-ec2-server"
  execution_role_arn = aws_iam_role.ebs_backup_role.arn

  policy_details {
    resource_types = ["VOLUME"]
    target_tags = {
      Backup = "true"
    }

    schedule {
      name = "DailyBackup"

      create_rule {
        interval      = 24
        interval_unit = "HOURS"
        times         = ["02:00"] # UTC time for 7:00 AM IST (8:30 PM EST previous day)
      }

      retain_rule {
        count = 7 # Retain snapshots for 7 days
      }

      tags_to_add = {
        CreatedBy = "EBSBackupPolicy"
      }
    }
  }

  state = "ENABLED"
}

# IAM Role for DLM to create snapshots
resource "aws_iam_role" "ebs_backup_role" {
  name = "${var.project_prefix}-ebs-backup-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "dlm.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# IAM Policy for DLM Role
resource "aws_iam_policy" "ebs_backup_policy" {
  name        = "${var.project_prefix}-ebs-backup-policy"
  description = "Policy to allow DLM to create EBS snapshots"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:CreateSnapshot",
          "ec2:DeleteSnapshot",
          "ec2:DescribeVolumes",
          "ec2:DescribeSnapshots",
          "ec2:DescribeTags",
          "ec2:CreateTags"
        ]
        Resource = "*"
      }
    ]
  })
}

# Attach the policy to the IAM role
resource "aws_iam_role_policy_attachment" "ebs_backup_policy_attachment" {
  role       = aws_iam_role.ebs_backup_role.name
  policy_arn = aws_iam_policy.ebs_backup_policy.arn
}


output "backend_ec2_instance_public_ip" {
  value = aws_instance.backend_ec2_server.public_ip
}