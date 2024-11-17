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

# Add Microsoft's repository for PowerShell for Ubuntu 22.04 (Jammy)
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - \
    && apt-add-repository "deb https://packages.microsoft.com/ubuntu/22.04/prod jammy main" \
    && apt-get update \
    && apt-get install -y powershell

# Install .NET SDK
RUN curl -sSL https://dotnet.microsoft.com/download/dotnet/scripts/v1/dotnet-install.sh | bash /dev/stdin

# Install .NET Runtime explicitly to avoid missing runtime error
RUN curl -sSL https://dotnet.microsoft.com/download/dotnet/scripts/v1/dotnet-install.sh | bash /dev/stdin --runtime dotnet

# Check that .NET is installed correctly
RUN echo "Dotnet is installed at: $(find /home/jovyan/.dotnet -type f -name 'dotnet')" \
    && ls -l /home/jovyan/.dotnet/

# Set up PATH for jovyan user to access dotnet
RUN echo "export PATH=\$PATH:/home/jovyan/.dotnet:/home/jovyan/.dotnet/tools" >> /etc/profile.d/dotnet.sh \
    && chmod +x /etc/profile.d/dotnet.sh

# Ensure that the PATH is updated and dotnet is available
RUN source /etc/profile.d/dotnet.sh && dotnet --version

# Install dotnet tool globally: Microsoft.dotnet-interactive
RUN source /etc/profile.d/dotnet.sh && dotnet tool install --global Microsoft.dotnet-interactive --version 1.0.155302 \
    --add-source "https://dotnet.myget.org/F/dotnet-try/api/v3/index.json" \
    && dotnet interactive jupyter install

# Set the default user to jovyan (the original user in jupyter/base-notebook)
USER jovyan

# Expose the Jupyter Notebook port
EXPOSE 8888

# Start Jupyter Notebook
CMD ["start-notebook.sh"]


