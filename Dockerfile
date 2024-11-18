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

# Install PowerShell from the Microsoft repository
RUN wget https://packages.microsoft.com/config/ubuntu/22.04/prod.list \
    -O /etc/apt/sources.list.d/microsoft-prod.list && \
    curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - && \
    apt-get update && \
    apt-get install -y powershell

# Install .NET 8.0 SDK and runtime via official Microsoft repositories
RUN wget https://packages.microsoft.com/config/ubuntu/22.04/prod.list \
    -O /etc/apt/sources.list.d/microsoft-prod.list && \
    curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - && \
    apt-get update && \
    apt-get install -y dotnet-sdk-8.0

# Create .dotnet/tools directory explicitly
RUN mkdir -p /root/.dotnet/tools

# Install .NET tool globally: Microsoft.dotnet-interactive
RUN dotnet tool install --global Microsoft.dotnet-interactive --version 1.0.155302 \
    --add-source "https://dotnet.myget.org/F/dotnet-try/api/v3/index.json"

# Set the PATH to include the .NET tools directory for the root user
ENV PATH="/root/.dotnet/tools:$PATH"

# Ensure the tool is installed by listing installed tools and dotnet version
RUN dotnet tool list -g && dotnet --version

# Explicitly ensure the path is available for subsequent commands by sourcing bashrc
RUN echo "source /home/jovyan/.bashrc" >> /root/.bashrc

# Ensure PATH and directory are correct, and list the tools
RUN echo "PATH is: $PATH" && \
    echo "Listing /root/.dotnet/tools:" && \
    ls -l /root/.dotnet/tools && \
    dotnet tool list -g

# Manually delete the tools directory if already exists to avoid cross-device link error
RUN rm -rf /root/.dotnet/tools

# Reinstall dotnet-interactive tool and install the Jupyter kernel
RUN dotnet tool install --global Microsoft.dotnet-interactive && \
    /root/.dotnet/tools/dotnet-interactive jupyter install

# Install the PowerShell kernel for Jupyter
RUN pwsh -Command "Install-Module -Name Jupyter -Force" && \
    pwsh -Command "Install-JupyterKernel"

# Set the PATH to include .NET tools and runtime for the jovyan user
ENV PATH="/home/jovyan/.dotnet:/home/jovyan/.dotnet/tools:$PATH"
ENV DOTNET_ROOT="/home/jovyan/.dotnet"
ENV DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1

# Force the shell to recognize the new environment variables and tools
RUN echo "export PATH=$PATH:/home/jovyan/.dotnet:/home/jovyan/.dotnet/tools" >> /home/jovyan/.bashrc && \
    source /home/jovyan/.bashrc && \
    dotnet --version && \
    dotnet tool list -g

# Switch back to the jovyan user (original user in jupyter/base-notebook)
USER jovyan

# Expose the Jupyter Notebook port
EXPOSE 8888

# Start Jupyter Notebook
CMD ["start-notebook.sh"]
