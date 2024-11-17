# Start with the Jupyter base image
FROM jupyter/base-notebook:latest

# Install dependencies and PowerShell with elevated privileges
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
    powershell \
    && rm -rf /var/lib/apt/lists/*

# Install .NET SDK (version 6.0.100 in this case)
RUN dotnet_sdk_version=6.0.100 \
    && curl -SL --output dotnet.tar.gz https://dotnetcli.azureedge.net/dotnet/Sdk/$dotnet_sdk_version/dotnet-sdk-$dotnet_sdk_version-linux-x64.tar.gz \
    && mkdir -p /usr/share/dotnet \
    && tar -ozxf dotnet.tar.gz -C /usr/share/dotnet \
    && rm dotnet.tar.gz \
    && ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet \
    && dotnet --version

# Verify the installation of PowerShell
RUN pwsh --version

# Verify the installation of .NET SDK
RUN dotnet --version
