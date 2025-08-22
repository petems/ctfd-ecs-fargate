FROM mcr.microsoft.com/devcontainers/base:ubuntu

# Install additional packages
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    unzip \
    jq \
    tree \
    htop \
    && rm -rf /var/lib/apt/lists/*

# Install terraform-docs
RUN wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | tee /usr/share/keyrings/hashicorp-archive-keyring.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list \
    && apt-get update \
    && apt-get install -y terraform-docs \
    && rm -rf /var/lib/apt/lists/*

# Set up shell aliases
RUN echo 'alias tf="terraform"' >> /home/vscode/.bashrc \
    && echo 'alias tfi="terraform init"' >> /home/vscode/.bashrc \
    && echo 'alias tfp="terraform plan"' >> /home/vscode/.bashrc \
    && echo 'alias tfa="terraform apply"' >> /home/vscode/.bashrc \
    && echo 'alias tfd="terraform destroy"' >> /home/vscode/.bashrc \
    && echo 'alias tfv="terraform validate"' >> /home/vscode/.bashrc \
    && echo 'alias tff="terraform fmt"' >> /home/vscode/.bashrc

# Create terraform config directory
RUN mkdir -p /home/vscode/.terraform.d && chown -R vscode:vscode /home/vscode/.terraform.d
