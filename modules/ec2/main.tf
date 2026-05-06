resource "aws_instance" "this" {
  ami                         = var.ami
  instance_type               = var.instance_type
  key_name                    = var.key_name
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = var.vpc_security_group_ids
  associate_public_ip_address = true
  user_data                   = <<-EOF
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

  tags = {
    Name = var.name
  }
}
