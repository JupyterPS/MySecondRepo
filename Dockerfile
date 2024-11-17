# Use Jupyter's base image
FROM jupyter/base-notebook:latest

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV DOTNET_CLI_TELEMETRY_OPTOUT=1
ENV POWERSHELL_TELEMETRY_OPTOUT=1

# Switch to root to install system packages
USER root

# Install required dependencies
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
    wget \
    && rm -rf /var/lib/apt/lists/*

# Install PowerShell
RUN wget -q https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb \
    && dpkg -i packages-microsoft-prod.deb \
    && apt-get update \
    && apt-get install -y powershell \
    && rm packages-microsoft-prod.deb

# Install the .NET SDK (6.0 version as an example)
RUN wget https://download.visualstudio.microsoft.com/download/pr/3a184f57-3f5a-4d95-bc55-4d857d839f38/3776d8304fd32a2f70311bb043da1607/dotnet-sdk-6.0.100-linux-x64.tar.gz \
    && mkdir -p /usr/share/dotnet \
    && tar -zxf dotnet-sdk-6.0.100-linux-x64.tar.gz -C /usr/share/dotnet \
    && rm dotnet-sdk-6.0.100-linux-x64.tar.gz \
    && ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet

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


