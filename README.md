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

## Design Principals
- Infrastructure is defined declaratively using Terraform
- No sensitive values (such as database credentials) are stored in Terraform state
- Secrets are retrieved  at runtime via AWS Secret Manager
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

---

## Terraform Bootstrap - Backend Infrastructure

### Purpose
This directory defines the bootstrap infrastructure required to operate Terraform 
safely and consistently for the Data Quality Validation Framework.

The bootstrap layer provisions shared backend resources used by all Terraform
environments, including:
- safe state management
- protection against concurrent state modifications
- predictable and auditable infrastructure changes

This layer is foundational prerequisite for all environment deployments.

### Scope of this directory
This directory manages only Terraform backend infrastructure, not application resources.

Specifically, it provisions:
- DynamoDB table for Terraform state locking
It doesn't manage:
- ECS, IAM, S3 or Secrets Manager resources
- environment-specific infrastructure
- application runtime components

### When to run bootstrap
Bootstrap should be executed:
- once per AWS account and region
- before running Terraform in any environment directory
After successful creation, bootstrap resources are treated as long-lived shared 
infrastructure.

### How ro run bootstrap
Prerequisites
- Terraform installed
- AWS credentials and permissions to create DynamoDB resources

Execution
From the **terraform/terraform-bootstrap** directory:
```bash
terraform init
terraform apply
```
Review the execution plan and confirm when promoted.

### After bootstrap
Once bootstrap has completed successfully:
- Do not use this directory for routine Terraform operations
- Proceed to environment-level Terraform usage:
```bash
cd ../envs/dev
terraform init
terraform plan
terraform apply
```
Each environment manages its own infrastructure and state independently, while
sharing the same backend locking mechanism.

--- 
## Event-Driven Execution (S3 → ECS)

The Data Quality Validation Framework supports **event-driven execution** using **Amazon EventBridge**.

When enabled, the system can automatically start a validation task in response to new data arriving in S3.

### How it works

1. A new object is uploaded to the input S3 bucket
2. Amazon EventBridge receives an `Object Created` event
3. EventBridge triggers an ECS Fargate task
4. The task receives runtime context via environment variables:
   - source S3 bucket
   - object key
5. The validation container processes the file and writes results to the results bucket

This mechanism allows the platform to operate in a **fully asynchronous, serverless, event-driven mode**.

---

### Supported file types

The S3 trigger can be configured to react only to specific file types using suffix filters.

By default, the following formats are supported:

- `.xlsx`
- `.csv`
- `.parquet`

Filtering is enforced at the EventBridge rule level to prevent unnecessary task executions.

---

### Scope and guarantees

- EventBridge rules are **explicitly defined and version-controlled**
- Only object creation events are handled
- Execution permissions are restricted to:
  - `ecs:RunTask`
  - `iam:PassRole` (scoped to the task role)
- No S3 polling or long-running listeners are used

This design ensures:
- predictable cost model
- clear audit trail
- strong separation of concerns

---

## Execution Models

The platform supports **event-driven execution** and is designed to support additional execution models as the system evolves.

### Implemented

| Mode | Description |
|-----|-------------|
| Event-driven | ECS task triggered automatically by S3 object creation events |

Event-driven execution is implemented using **Amazon EventBridge** and **ECS Fargate**.
