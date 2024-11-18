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
RUN curl https://packages.microsoft.com/config/ubuntu/22.04/prod.list | tee /etc/apt/sources.list.d/microsoft-prod.list \
    && curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - \
    && apt-get update \
    && apt-get install -y dotnet-runtime-3.1 \
    && rm -rf /var/lib/apt/lists/*

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
