# Terraform Learn Project (AWS VPC + ALB + ASG)

This repository is a beginner-friendly Terraform project that creates a simple AWS infrastructure using modules:

- A **VPC** with:
  - internet gateway
  - public subnets created with `count`
  - route table + association
  - security groups for the load balancer and EC2 instances
- An **Application Load Balancer** listening on HTTP port `80`
- An **Auto Scaling Group** that launches EC2 instances with:
  - desired capacity: `2`
  - minimum size: `2`
  - maximum size: `3`



---

## 1) What You Are Building

When you run this project, Terraform creates:

1. `aws_vpc`  
2. `aws_internet_gateway` attached to that VPC  
3. `aws_subnet` public subnets using `count`  
4. `aws_route_table` with default route `0.0.0.0/0 -> Internet Gateway`  
5. `aws_route_table_association` to connect subnets with route table  
6. `aws_security_group` resources for ALB and EC2 traffic  
7. `aws_lb`, `aws_lb_target_group`, and `aws_lb_listener`  
8. `aws_launch_template` and `aws_autoscaling_group`  

At the end, Terraform outputs the ALB DNS name and ASG name.

---

## 2) Project Structure

```text
terraform-learn/
├── main.tf
├── variables.tf
├── outputs.tf
├── dev.tfvars
├── prod.tfvars
└── modules/
    ├── vpc/
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── alb/
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    └── ec2/
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

### Root files

- `main.tf`
  - Defines Terraform + provider requirements
  - Configures remote state backend (S3)
  - Calls `vpc` and `ec2` modules
- `variables.tf`
  - Input variables for region, naming, networking, and EC2 settings
- `outputs.tf`
  - Exposes ALB DNS name and ASG name from module outputs
- `dev.tfvars` and `prod.tfvars`
  - Environment-specific values (`environment`, CIDRs, etc.)

### Module files

- `modules/vpc/*`
  - Handles networking, public subnets, and security groups
- `modules/alb/*`
  - Handles Application Load Balancer, listener, and target group
- `modules/ec2/*`
  - Handles launch template and Auto Scaling Group

---

## 3) Terraform Concepts Used Here

### Provider

You use the AWS provider (`hashicorp/aws`) to create AWS resources.

### Backend

State is configured in `main.tf` with an S3 backend:

- bucket: `my-terraform-state-0001232324`
- key: `dev/terraform.tfstate`
- region: `us-east-1`

This means Terraform state is stored remotely in S3 instead of only local file.

### Variables and tfvars

Variables are declared in `variables.tf` and values are passed from:

- `dev.tfvars` for development
- `prod.tfvars` for production

### Locals

`local.name_prefix` builds a reusable naming pattern:

`<project_name>-<environment>`

### Modules

Modules split infrastructure into reusable logical parts:

- VPC module outputs subnet/security group IDs
- EC2 module consumes those outputs

This is a very important real-world Terraform pattern.

---

## 4) Prerequisites

Before using this project, install and configure:

1. **Terraform** (>= 1.5.0)
2. **AWS CLI** (optional but recommended)
3. **AWS credentials** with permissions for:
   - VPC/network resources
   - EC2 instance resources
   - S3 state bucket access (read/write for backend)
4. Existing **EC2 Key Pair** in AWS (matches `key_name` in tfvars)

Check tools:

```bash
terraform version
aws sts get-caller-identity
```

---

## 5) How to Run (Step by Step)

Run from repository root:

### Step 1: Initialize

```bash
terraform init
```

What it does:

- Downloads provider plugins
- Configures backend
- Prepares module dependencies

### Step 2: Format and Validate

```bash
terraform fmt -recursive
terraform validate
```

### Step 3: Plan (Dev)

```bash
terraform plan -var-file=dev.tfvars
```

### Step 4: Apply (Dev)

```bash
terraform apply -var-file=dev.tfvars
```

Type `yes` when prompted.

### Step 5: Get Outputs

```bash
terraform output
```

You should see `alb_dns_name` and `asg_name`.

---

## 6) Working with Multiple Environments

This project has two tfvars files:

- `dev.tfvars`
- `prod.tfvars`

Use the matching file in plan/apply:

```bash
terraform plan  -var-file=prod.tfvars
terraform apply -var-file=prod.tfvars
```

Important note: backend key is currently fixed to `dev/terraform.tfstate` in `main.tf`.  
If you truly want separate remote states for dev/prod, you should use different backend configurations (or workspaces plus safe backend key strategy).

---

## 7) How Values Flow in This Project

1. Root variables are loaded from `*.tfvars`.
2. Root module computes `local.name_prefix`.
3. Root calls `module.vpc` with networking + SSH CIDR values.
4. VPC module creates network resources and outputs:
   - `public_subnet_ids`
   - `alb_security_group_id`
   - `ec2_security_group_id`
5. Root passes subnet and ALB security group outputs into `module.alb`.
6. Root passes subnet, EC2 security group, and target group outputs into `module.ec2`.
7. EC2 module creates a launch template and ASG with desired/min `2` and max `3`.
8. Root output returns `alb_dns_name` and `asg_name`.

---

## 8) Destroy Resources

To avoid AWS charges, destroy when done:

```bash
terraform destroy -var-file=dev.tfvars
```

Or for prod values:

```bash
terraform destroy -var-file=prod.tfvars
```

---

## 9) Common Beginner Issues and Fixes

### 1) `No valid credential sources found`

- Configure AWS credentials (`aws configure`)
- Or use environment variables (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`)

### 2) `InvalidKeyPair.NotFound`

- `key_name` in tfvars does not exist in that region
- Create/import key pair and update `key_name`

### 3) Cannot SSH into EC2

- Ensure your local private key matches `key_name`
- Ensure EC2 is in running state and has public IP
- Check security group allows your IP (not just `0.0.0.0/0`)

### 4) Backend S3 errors

- Verify bucket exists
- Verify IAM policy allows S3 backend operations

---

## 10) Security and Best-Practice Improvements (Recommended)

This project is great for learning, but for production you should improve:

1. Restrict SSH access:
   - replace `allowed_ssh_cidr = "0.0.0.0/0"` with your public IP CIDR (for example `x.x.x.x/32`)
2. Add tags consistently:
   - owner, environment, cost-center
3. Use separate backend keys (or backend configs) per environment
4. Consider private subnets + bastion/SSM instead of direct public SSH
5. Add `terraform plan` in CI before apply

---

## 11) Useful Commands Cheat Sheet

```bash
# initialize
terraform init

# format files
terraform fmt -recursive

# validate configuration
terraform validate

# plan with environment values
terraform plan -var-file=dev.tfvars

# apply with environment values
terraform apply -var-file=dev.tfvars

# show outputs
terraform output

# destroy resources
terraform destroy -var-file=dev.tfvars
```

---

## 12) Learning Path (Suggested)

If you are learning Terraform, try this order:

1. Read root `main.tf` and identify module inputs
2. Read `modules/vpc/main.tf` to understand networking dependencies
3. Read `modules/ec2/main.tf` to understand compute configuration
4. Run `terraform plan` and observe execution graph mentally
5. Change one variable (like `instance_type`) and plan again
6. Add one new output (for example `instance_id`) at root
7. Destroy and recreate to practice full lifecycle

---

## 13) Current Configuration Snapshot

- AWS region: `us-east-1`
- AMI: `ami-`
- Instance type: `t3.small`
- Environments configured: `dev`, `prod`
- Remote backend: S3 bucket `my-terraform-state-`

---
