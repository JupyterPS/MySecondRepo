# Start with the Jupyter base image
FROM jupyter/base-notebook:latest

# Install required dependencies and add the Microsoft repository for PowerShell
USER root

RUN apt-get update \
    && apt-get install -y \
    curl \
    libssl-dev \
    libicu-dev \
    libssl3 \
    gnupg \
    lsb-release \
    wget \
    apt-transport-https \
    software-properties-common \
    unzip \
    && curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg \
    && mv microsoft.gpg /etc/apt/trusted.gpg.d/microsoft.gpg \
    && sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/microsoft-ubuntu-jammy-prod jammy main" > /etc/apt/sources.list.d/microsoft.list' \
    && apt-get update \
    && apt-get install -y powershell \
    && rm -rf /var/lib/apt/lists/*

# Install .NET SDK (version 6.0.100 in this case)
RUN dotnet_sdk_version=6.0.100 \
    && curl -SL --output dotnet.tar.gz https://dotnetcli.azureedge.net/dotnet/Sdk/$dotnet_sdk_version/dotnet-sdk-$dotnet_sdk_version-linux-x64.tar.gz \
    && mkdir -p /usr/share/dotnet \
    && tar -ozxf dotnet.tar.gz -C /usr/share/dotnet \
    && rm dotnet.tar.gz \
    && ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet \
    && dotnet --version

# Verify PowerShell installation
RUN pwsh --version

# Verify .NET SDK installation
RUN dotnet --version

