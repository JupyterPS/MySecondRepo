# Start with Jupyter base image
FROM jupyter/base-notebook:latest

# Switch to root to install additional packages
USER root

# Install PowerShell, .NET SDK, and required dependencies
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
    powershell \
    && rm -rf /var/lib/apt/lists/*

# Install .NET SDK (You can choose a specific version as needed)
RUN dotnet_sdk_version=6.0.100 \
    && curl -SL --output dotnet.tar.gz https://dotnetcli.azureedge.net/dotnet/Sdk/$dotnet_sdk_version/dotnet-sdk-$dotnet_sdk_version-linux-x64.tar.gz \
    && dotnet_sha512='sha512sum_here' \
    && echo "$dotnet_sha512 dotnet.tar.gz" | sha512sum -c - \
    && mkdir -p /usr/share/dotnet \
    && tar -ozxf dotnet.tar.gz -C /usr/share/dotnet \
    && rm dotnet.tar.gz \
    && ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet \
    && dotnet --version

# Install .NET Interactive
RUN dotnet tool install --global Microsoft.dotnet-interactive --version 1.0.155302 --add-source "https://dotnet.myget.org/F/dotnet-try/api/v3/index.json"

# Clean up
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Switch back to the jovyan user for Jupyter operations
USER jovyan

# Set environment variable to opt-out of telemetry
ENV DOTNET_CLI_TELEMETRY_OPTOUT=true

# Expose the Jupyter notebook port
EXPOSE 8888

# Expose PowerShell for shell access
EXPOSE 4051

# Start the Jupyter notebook and PowerShell for terminal
CMD ["start-notebook.sh"]
