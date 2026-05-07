resource "aws_launch_template" "this" {
  name_prefix   = "${var.name}-"
  image_id      = var.ami
  instance_type = var.instance_type
  key_name      = var.key_name

  user_data = base64encode(<<-EOF
              #!/bin/bash
              set -eux
              dnf update -y
              dnf install -y nginx
              systemctl enable nginx
              systemctl start nginx
              cat > /usr/share/nginx/html/index.html <<'HTML'
              <!doctype html>
              <html lang="en">
              <head>
                <meta charset="UTF-8" />
                <meta name="viewport" content="width=device-width, initial-scale=1.0" />
                <title>Welcome</title>
                <style>
                  body { font-family: Arial, sans-serif; margin: 40px; background: #f5f7fb; }
                  .card { background: #fff; border-radius: 10px; padding: 24px; max-width: 700px; box-shadow: 0 6px 20px rgba(0,0,0,0.08); }
                  h1 { margin-top: 0; color: #0f172a; }
                  p { color: #334155; }
                </style>
              </head>
              <body>
                <div class="card">
                  <h1>Nginx is running on ${var.name}</h1>
                  <p>This page was provisioned automatically with Terraform user_data.</p>
                </div>
              </body>
              </html>
              HTML
              EOF
  )

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = var.vpc_security_group_ids
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = var.name
    }
  }
}

resource "aws_autoscaling_group" "this" {
  name                      = "${var.name}-asg"
  desired_capacity          = var.desired_capacity
  min_size                  = var.min_size
  max_size                  = var.max_size
  vpc_zone_identifier       = var.subnet_ids
  target_group_arns         = var.target_group_arns
  health_check_type         = "ELB"
  health_check_grace_period = 300

  launch_template {
    id      = aws_launch_template.this.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = var.name
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "cpu_target_tracking" {
  name                   = "${var.name}-cpu-target-tracking"
  autoscaling_group_name = aws_autoscaling_group.this.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 75.0
  }
}
