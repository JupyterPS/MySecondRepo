# Use official .NET 8 SDK image
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build

# Install dependencies required for dotnet-interactive and Jupyter
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

# Manually download and install .NET Core 3.1 runtime
RUN wget https://download.visualstudio.microsoft.com/download/pr/1a6b7f1c-1b78-4b5c-93c9-1b27d8e8da7f/c1cd27f7c3464f0c2c0a24b96a1a59b5/dotnet-runtime-3.1.32-linux-x64.tar.gz -O /tmp/dotnet-runtime-3.1.32-linux-x64.tar.gz \
    && mkdir -p /usr/share/dotnet \
    && tar -xzf /tmp/dotnet-runtime-3.1.32-linux-x64.tar.gz -C /usr/share/dotnet \
    && rm /tmp/dotnet-runtime-3.1.32-linux-x64.tar.gz

# Install dotnet-interactive globally in the specified path
RUN dotnet tool install Microsoft.dotnet-interactive --version 1.0.155302 \
    --add-source "https://dotnet.myget.org/F/dotnet-try/api/v3/index.json" \
    --tool-path /usr/local/.dotnet/tools

# Install Jupyter integration for dotnet-interactive
RUN /usr/local/.dotnet/tools/dotnet-interactive jupyter install

# Verify installation
RUN dotnet --version && dotnet tool list -g

# Default command to start the container (optional)
# Uncomment this to start Jupyter automatically when the container runs
# CMD ["/usr/local/.dotnet/tools/dotnet-interactive", "jupyter", "notebook"]
