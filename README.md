# Infrastructure as Code – Terraform

## Purpose

**Infrastructure as Code (IaC)** for the **Data Quality Validation Framework**, implemented using **Terraform**.

The goal of this Terraform project is to:
- establish a **production-ready infrastructure definition**
- prove a **repeatable, clear, and auditable** deployment model
- define **IAM, networking, and resource layout** in a consistent and controlled manner

The infrastructure design follows AWS and Terraform best practices, with a strong focus on security, isolation and maintainability. 

---

## Environments
This project uses **directory-based environments** to manage deployments:
```
terraform/
  envs/
    dev/
    prod/
```    

### Enviromental model

- Terraform workspaces are **not used**
- Each environment:
  - has its own backend configuration
  - maintains an independent Terraform state
  - is fully isolated from other environments
- Environment-specific values are managed via `terraform.tfvars`

This approach provides explicit separation between environments and avoids hidden state coupling.

---

## Validation status

The Terraform configuration has been validated using:
```bash
terraform init
terraform plan
```
Successful planning confirms that:
- backend configuration is correct
- required providers are resolved
- infrastructure definitions are syntactically and logically valid

## Designed Principals
- Infrastructure is defined declaratively using Terraform
- No sensitive values (such as database credentials) are stored in Terraform state
- Secrets retrieved  at runtime via AWS Secret Manager
- IAM permissions follow the principle of least privilege
- All resources are named consistently and scoped per environment

---

## Usage Notes
Terraform is intended to be the source of truth for infrastructure definition.

Changes to infrastructure should be introduced through:
1. code changes
2. **terraform plan** review
3. controlled **terraform apply**
This ensures predictable, traceable, and reviewable infrastructure changes.
