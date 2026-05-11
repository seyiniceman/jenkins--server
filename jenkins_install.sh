#!/bin/bash

# Log everything (VERY IMPORTANT)
exec > >(tee /var/log/user-data.log | logger -t user-data -s 2>/dev/console) 2>&1

# Fail fast
set -euxo pipefail

echo "=== STARTING SETUP ==="

export DEBIAN_FRONTEND=noninteractive

########################################
# BASE SETUP
########################################
apt-get update -y
apt-get install -y ca-certificates curl gnupg lsb-release software-properties-common

install -m 0755 -d /etc/apt/keyrings

########################################
# JAVA + BASIC TOOLS
########################################
apt-get install -y openjdk-21-jdk git maven
# Force the system to use Java 21
update-java-alternatives --set $(ls -d /usr/lib/jvm/java-1.21.0-openjdk-amd64 | head -n 1)
########################################
# JENKINS (2026 UPDATED KEY & FIX)
########################################
echo "=== Installing Jenkins ==="

# 1. Download the LATEST 2026 key (Jenkins changed this recently)
# The backslash '\' is critical to keep this as one command
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2026.key | \
gpg --dearmor -o /etc/apt/keyrings/jenkins.gpg

# 2. Ensure the key is readable by the system
chmod a+r /etc/apt/keyrings/jenkins.gpg

# 3. Create the source list pointing to the new .gpg file
echo "deb [signed-by=/etc/apt/keyrings/jenkins.gpg] https://pkg.jenkins.io/debian-stable binary/" > /etc/apt/sources.list.d/jenkins.list

########################################
# DOCKER
########################################
echo "=== Installing Docker ==="

curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
| gpg --dearmor --yes -o /etc/apt/keyrings/docker.gpg

chmod a+r /etc/apt/keyrings/docker.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
> /etc/apt/sources.list.d/docker.list

########################################
# TERRAFORM (HashiCorp)
########################################
echo "=== Installing Terraform ==="

curl -fsSL https://apt.releases.hashicorp.com/gpg \
| gpg --dearmor --yes -o /etc/apt/keyrings/hashicorp.gpg

chmod a+r /etc/apt/keyrings/hashicorp.gpg

echo "deb [signed-by=/etc/apt/keyrings/hashicorp.gpg] \
https://apt.releases.hashicorp.com $(lsb_release -cs) main" \
> /etc/apt/sources.list.d/hashicorp.list

########################################
# KUBERNETES (UPDATED REPO)
########################################
echo "=== Installing kubectl ==="

curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key \
| gpg --dearmor --yes -o /etc/apt/keyrings/kubernetes.gpg

chmod a+r /etc/apt/keyrings/kubernetes.gpg

echo "deb [signed-by=/etc/apt/keyrings/kubernetes.gpg] \
https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /" \
> /etc/apt/sources.list.d/kubernetes.list

########################################
# UPDATE (CRITICAL CHECK)
########################################
apt-get update -y || { echo "APT UPDATE FAILED"; exit 1; }

########################################
# INSTALL ALL TOOLS
########################################
apt-get install -y \
jenkins \
docker-ce docker-ce-cli containerd.io \
terraform \
kubectl \
awscli

########################################
# HELM (LATEST)
########################################
echo "=== Installing Helm ==="
curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

########################################
# SERVICES
########################################
systemctl daemon-reexec

systemctl enable docker
systemctl start docker

systemctl enable jenkins
systemctl start jenkins

########################################
# POST SETUP
########################################
usermod -aG docker ubuntu

echo "=== Jenkins Initial Password ==="
cat /var/lib/jenkins/secrets/initialAdminPassword || true

echo "=== SETUP COMPLETE ==="
