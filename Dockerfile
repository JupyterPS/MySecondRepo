# Use Jupyter's base image
FROM jupyter/base-notebook:latest

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV DOTNET_CLI_TELEMETRY_OPTOUT=1
ENV POWERSHELL_TELEMETRY_OPTOUT=1
ENV DOTNET_ROOT=/usr/share/dotnet

# Switch to root to install system packages
USER root

# Install required dependencies and Microsoft's package signing key
RUN apt-get update && apt-get install -y \
    curl \
    libssl-dev \
    libicu-dev \
    gnupg \
    lsb-release \
    wget \
    apt-transport-https \
    software-properties-common \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Install .NET SDK via the dotnet-install.sh script
RUN curl -sSL https://dotnet.microsoft.com/download/dotnet/scripts/v1/dotnet-install.sh | bash /dev/stdin

# Ensure the dotnet binaries are available in the path
ENV PATH="$PATH:/root/.dotnet"

# Verify .NET SDK installation
RUN dotnet --version

# Install PowerShell
RUN wget -q https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb \
    && dpkg -i packages-microsoft-prod.deb \
    && apt-get update \
    && apt-get install -y powershell \
    && rm packages-microsoft-prod.deb

# Install .NET Interactive for PowerShell Jupyter Kernel
RUN dotnet tool install --global Microsoft.dotnet-interactive --version 1.0.155302 \
    --add-source "https://dotnet.myget.org/F/dotnet-try/api/v3/index.json" \
    && dotnet interactive jupyter install

# Update PATH to include dotnet tools
ENV PATH="$PATH:/root/.dotnet/tools"

# Verify PowerShell and dotnet installation
RUN dotnet --version
RUN powershell --version

# Switch back to non-root user
USER $NB_UID




