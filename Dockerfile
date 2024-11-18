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

# Install .NET Core 3.1 runtime (for dotnet-interactive compatibility)
RUN wget https://download.visualstudio.microsoft.com/download/pr/ff4f37d9-3b45-4d57-bbd5-dc57e1b2b38d/404e772be1c0f4189fbb65efadfe9ed1/dotnet-runtime-3.1.32-linux-x64.tar.gz -O /tmp/dotnet-runtime-3.1.32-linux-x64.tar.gz \
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
