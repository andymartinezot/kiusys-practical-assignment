# Kiusys Practical Assignment

This project deploys and scales a containerized application using AWS-managed Kubernetes (EKS), Amazon Aurora PostgreSQL, and AWS ALB Ingress Controller. Infrastructure is provisioned using modular Terraform code, and the application is deployed using raw Kubernetes manifests (no Helm).

---

## ✅ Features

- Modular Terraform code (VPC, EKS, RDS)
- EKS cluster with auto-scaling managed node groups
- Aurora PostgreSQL (Multi-AZ, encrypted, private subnets)
- Public HTTPS access via ALB created by Kubernetes Ingress
- Remote Terraform state with locking using S3 + DynamoDB
- Application deployed with raw YAML manifests

---

## 📦 Project Structure

```
kiusys-practical-assignment/
├── terraform/                  # Terraform IaC
│   ├── backend/               # Remote backend config
│   ├── modules/               # Modular components (vpc, eks, rds)
│   ├── main.tf                # Root terraform entrypoint
│   ├── variables.tf
│   └── outputs.tf
├── k8s-manifests/             # Raw K8s deployment files
├── scripts/                   # Utility scripts
└── README.md
```

---

## 🔐 Terraform Remote State & Locking

Terraform backend is configured to use:
- **S3 Bucket**: `kiusys-tf-remote-state` for state file storage
- **DynamoDB Table**: `kiusys-terraform-state-lock` for locking

Config stored in:

```hcl
terraform/backend/backend.tfvars
```

Contents:

```hcl
bucket         = "kiusys-tf-remote-state"
key            = "terraform.tfstate"
region         = "us-east-1"
dynamodb_table = "kiusys-terraform-state-lock"
encrypt        = true
```

---

## 🚀 How to Deploy

### 1. Initialize Terraform

```bash
cd terraform
terraform init -backend-config=backend/backend.tfvars
```

### 2. Apply Infrastructure

```bash
terraform apply
```

### 3. Deploy Kubernetes App

Make sure your `kubectl` is pointing to the new EKS cluster (Terraform sets it up automatically):

```bash
chmod +x scripts/deploy_k8s_resources.sh
./scripts/deploy_k8s_resources.sh
```

---

## ⚙️ Requirements

- Terraform ≥ 1.5
- AWS CLI configured with appropriate IAM permissions
- kubectl ≥ 1.29
- AWS Load Balancer Controller installed in EKS (required for ALB Ingress)

---

## 🔒 Security Best Practices

- RDS in private subnets, not publicly accessible
- TLS encryption via ACM-managed certificate and ALB Ingress
- State file encryption + locking using S3 and DynamoDB
- IAM roles assigned to EKS nodes or IRSA (recommended)

---

## 📌 Notes

- **Do NOT define ALB manually in Terraform** — the ALB is created dynamically by the Kubernetes Ingress resource via the AWS Load Balancer Controller.
- Ensure your EKS nodes or service account have IAM permissions to manage ALB and Route53 (if using DNS).

---

## 🌍 How to Expose the Application Publicly with Route 53

This project uses the [AWS Load Balancer Controller](https://kubernetes-sigs.github.io/aws-load-balancer-controller) and [ExternalDNS](https://github.com/kubernetes-sigs/external-dns) to expose the application via HTTPS using a custom domain (`kiusys.amartinezot.com`).

### Steps to expose the app publicly:

1. ✅ **Ensure Hosted Zone Exists**  
   Make sure `amartinezot.com` is a public hosted zone in Route 53.

2. ✅ **Use Ingress with ALB Annotations**  
   Your Ingress must include annotations like:
   ```yaml
   alb.ingress.kubernetes.io/scheme: internet-facing
   alb.ingress.kubernetes.io/certificate-arn: <your-acm-certificate-arn>
   external-dns.alpha.kubernetes.io/hostname: kiusys.amartinezot.com
   ```

3. ✅ **ACM Certificate for HTTPS**  
   Request or import an ACM certificate for `kiusys.amartinezot.com` in region `us-east-1`. Use DNS validation with Route 53.

4. ✅ **Install ExternalDNS**  
   Deploy `external-dns` to your cluster to automatically create DNS records in Route 53. ExternalDNS watches for Ingress annotations and syncs with Route 53.

5. ✅ **IAM Permissions for ExternalDNS**  
   Ensure ExternalDNS has permissions to manage Route 53 (either via IRSA or node IAM role). Example policy:
   ```json
   {
     "Effect": "Allow",
     "Action": [
       "route53:ChangeResourceRecordSets",
       "route53:ListHostedZones",
       "route53:ListResourceRecordSets"
     ],
     "Resource": "*"
   }
   ```

6. ✅ **Verify Access**
   After deployment:
   - Check Route 53 to see the `kiusys.amartinezot.com` record
   - Visit `https://kiusys.amartinezot.com` in your browser

This approach eliminates the need for manual Route 53 configuration while enabling secure, scalable public access via HTTPS.