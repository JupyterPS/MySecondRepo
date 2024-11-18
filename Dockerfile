# Base image with Jupyter
FROM jupyter/base-notebook:latest

# Set environment variables to skip telemetry
ENV DEBIAN_FRONTEND=noninteractive
ENV DOTNET_CLI_TELEMETRY_OPTOUT=1
ENV POWERSHELL_TELEMETRY_OPTOUT=1

# Switch to root user to install system packages
USER root

# Install dependencies for dotnet and PowerShell
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

# Install .NET 8 SDK and runtime
RUN apt-get update && apt-get install -y \
    dotnet-sdk-8.0 \
    dotnet-runtime-8.0 \
    && rm -rf /var/lib/apt/lists/*

# Install .NET Core 3.1 manually
RUN wget https://download.visualstudio.microsoft.com/download/pr/17d566c0-dfc1-4e73-94ff-7ed2070e7a2d/af98cc2b7f39f58c0e5a31fc173da6e4/dotnet-runtime-3.1.32-linux-x64.tar.gz -O /tmp/dotnet-runtime-3.1.32-linux-x64.tar.gz \
    && mkdir -p /usr/share/dotnet \
    && tar -xzf /tmp/dotnet-runtime-3.1.32-linux-x64.tar.gz -C /usr/share/dotnet \
    && rm /tmp/dotnet-runtime-3.1.32-linux-x64.tar.gz

# Install PowerShell
RUN wget https://packages.microsoft.com/config/ubuntu/22.04/prod.list \
    -O /etc/apt/sources.list.d/microsoft-prod.list && \
    curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - && \
    apt-get update && \
    apt-get install -y powershell

# Clean and install dotnet-interactive tool
RUN rm -rf /root/.dotnet/tools && \
    dotnet tool install Microsoft.dotnet-interactive --version 1.0.155302 \
    --add-source "https://dotnet.myget.org/F/dotnet-try/api/v3/index.json" \
    --tool-path /usr/local/.dotnet/tools

# Set the path to include the tools directory
ENV PATH="/usr/local/.dotnet/tools:$PATH"

# Check if dotnet-interactive is installed correctly
RUN dotnet tool list -g && dotnet --version

# Install Jupyter kernel for dotnet-interactive
RUN /usr/local/.dotnet/tools/dotnet-interactive jupyter install

# Install PowerShell Jupyter kernel
RUN pwsh -Command "Install-Module -Name Jupyter -Force" && \
    pwsh -Command "Install-JupyterKernel"

# Set PATH and DOTNET_ROOT for jovyan user
ENV PATH="/home/jovyan/.dotnet:/home/jovyan/.dotnet/tools:$PATH"
ENV DOTNET_ROOT="/home/jovyan/.dotnet"
ENV DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1

# Force environment variables to apply
RUN echo "export PATH=$PATH:/home/jovyan/.dotnet:/home/jovyan/.dotnet/tools" >> /home/jovyan/.bashrc && \
    source /home/jovyan/.bashrc && \
    dotnet --version && \
    dotnet tool list -g

# Switch back to jovyan user for Jupyter
USER jovyan

# Expose the Jupyter Notebook port
EXPOSE 8888

# Start Jupyter Notebook
CMD ["start-notebook.sh"]
