# Jenkins Server Provisioning using Terraform

Provision a Jenkins Continuous Integration (CI) server on AWS using Terraform and automate the installation of Jenkins and Docker through shell scripts.

---

## Project Overview

This project demonstrates how to provision a Jenkins server on AWS using Terraform while automating the installation and configuration of Jenkins and Docker through Bash scripts.

The infrastructure is deployed using Infrastructure as Code (IaC), allowing the Jenkins server to be recreated consistently and reliably. The automated installation eliminates manual configuration, ensuring a repeatable deployment process suitable for Continuous Integration (CI) environments.

This project demonstrates practical DevOps skills including cloud provisioning, automation, Linux administration, Infrastructure as Code, and CI server deployment.

---

## Architecture Diagram

```text
                 +----------------------+
                 |      Developer       |
                 +----------+-----------+
                            |
                            | terraform apply
                            v
                 +----------------------+
                 |      Terraform       |
                 +----------+-----------+
                            |
                            v
                 +----------------------+
                 |      AWS EC2         |
                 +----------+-----------+
                            |
             +--------------+--------------+
             |                             |
             v                             v
   docker-install.sh          jenkins_install.sh
             |                             |
             +--------------+--------------+
                            |
                            v
                 Jenkins & Docker Installed
                            |
                            v
               Access Jenkins via Browser
```

---

## Objectives

- Provision an EC2 instance using Terraform.
- Automate Jenkins installation.
- Automate Docker installation.
- Eliminate manual server configuration.
- Demonstrate Infrastructure as Code (IaC).
- Build a reusable Jenkins deployment process.

---

## Technologies Used

- AWS EC2
- Terraform
- Jenkins
- Docker
- Bash
- Linux
- Git
- AWS CLI

---

## Repository Structure

- main.tf
- jenkins_install.sh
- docker-install.sh
- README.md

---

## Workflow

1. Clone the repository.
2. Initialize Terraform.
3. Provision an EC2 instance on AWS.
4. Execute the Docker installation script.
5. Execute the Jenkins installation script.
6. Access the Jenkins web interface.
7. Complete the Jenkins initial setup.
8. Install required Jenkins plugins.
9. Create CI/CD pipelines.

---

## Prerequisites

- AWS Account
- AWS CLI configured
- Terraform installed
- SSH Key Pair
- Git

---

## Deployment Steps

1. Clone the repository.

```bash
git clone <repository-url>
```

2. Initialize Terraform.

```bash
terraform init
```

3. Review the execution plan.

```bash
terraform plan
```

4. Provision infrastructure.

```bash
terraform apply
```

5. Connect to the EC2 instance.

```bash
ssh -i key.pem ec2-user@<public-ip>
```

6. Verify Jenkins service.

```bash
systemctl status jenkins
```

7. Verify Docker.

```bash
docker --version
```

8. Access Jenkins.

```
http://<EC2-Public-IP>:8080
```

---

## Skills Demonstrated

- Infrastructure as Code (Terraform)
- AWS EC2 Provisioning
- Jenkins Installation
- Docker Installation
- Bash Scripting
- Linux Administration
- Automation
- Continuous Integration (CI)
- Git

---

## Project Outcome

Successfully provisioned an AWS EC2 instance using Terraform and automated the installation of Jenkins and Docker through Bash scripts. The solution provides a repeatable, Infrastructure as Code deployment process that eliminates manual configuration and establishes a ready-to-use Continuous Integration environment for DevOps workflows.

# Author

**Seyi Akinmusere**

DevOps | Cloud Engineer | AWS | Terraform | Jenkins | Docker | Kubernetes

