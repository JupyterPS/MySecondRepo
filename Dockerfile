# Use Jupyter's base image
FROM jupyter/base-notebook:latest

# Set environment variables to skip telemetry
ENV DEBIAN_FRONTEND=noninteractive
ENV DOTNET_CLI_TELEMETRY_OPTOUT=1
ENV POWERSHELL_TELEMETRY_OPTOUT=1

# Switch to root user to install system packages
USER root

# Install required dependencies for dotnet and PowerShell
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

# Install .NET 8.0 SDK and runtime via official Microsoft repositories
RUN wget https://packages.microsoft.com/config/ubuntu/22.04/prod.list \
    -O /etc/apt/sources.list.d/microsoft-prod.list && \
    curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - && \
    apt-get update && \
    apt-get install -y dotnet-sdk-8.0

# Install .NET tool globally: Microsoft.dotnet-interactive
RUN dotnet tool install --global Microsoft.dotnet-interactive --version 1.0.155302 \
    --add-source "https://dotnet.myget.org/F/dotnet-try/api/v3/index.json" \
    && dotnet interactive jupyter install

# Set PATH for the dotnet tools and runtime
ENV PATH="/home/jovyan/.dotnet:/home/jovyan/.dotnet/tools:$PATH"
ENV DOTNET_ROOT="/home/jovyan/.dotnet"
ENV DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1

# Verify .NET installation and version
RUN dotnet --version

# Set the default user to jovyan (the original user in jupyter/base-notebook)
USER jovyan

# Expose the Jupyter Notebook port
EXPOSE 8888

# Start Jupyter Notebook
CMD ["start-notebook.sh"]




