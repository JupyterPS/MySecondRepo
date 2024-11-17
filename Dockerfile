# Start with a Jupyter base image
FROM jupyter/base-notebook:latest

# Install essential dependencies
RUN apt-get update && apt-get install -y \
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
    && rm -rf /var/lib/apt/lists/*

# Add Microsoft repository and key for PowerShell
RUN curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg \
    && mv microsoft.gpg /etc/apt/trusted.gpg.d/microsoft.gpg \
    && sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/microsoft-ubuntu-jammy-prod jammy main" > /etc/apt/sources.list.d/microsoft.list'

# Install PowerShell
RUN apt-get update && apt-get install -y powershell

# Install the desired version of .NET SDK
RUN dotnet_sdk_version=6.0.100 \
    && curl -SL --output dotnet.tar.gz https://dotnetcli.azureedge.net/dotnet/Sdk/$dotnet_sdk_version/dotnet-sdk-$dotnet_sdk_version-linux-x64.tar.gz \
    && echo "d77cce99d3ba3b5d6f61cfde36f3542704e834f366285305db130f6d9ec4f6d4 dotnet.tar.gz" | sha512sum -c - \
    && mkdir -p /usr/share/dotnet \
    && tar -ozxf dotnet.tar.gz -C /usr/share/dotnet \
    && rm dotnet.tar.gz \
    && ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet

# Verify PowerShell and .NET installation
RUN pwsh --version && dotnet --version

# Cleanup unnecessary files to reduce image size
RUN rm -rf /var/lib/apt/lists/*


