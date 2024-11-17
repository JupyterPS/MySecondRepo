# Start from the official .NET SDK image
FROM mcr.microsoft.com/dotnet/sdk:3.1 AS build

# Install .NET Interactive
RUN dotnet tool install --global Microsoft.dotnet-interactive --version 1.0.155302 --add-source "https://dotnet.myget.org/F/dotnet-try/api/v3/index.json"

# Install other dependencies and Jupyter
FROM jupyter/base-notebook:latest

USER root

# Install additional dependencies
RUN apt-get update && apt-get install -y \
    curl \
    libssl-dev \
    libssl3 \
    libicu-dev \
    gnupg \
    lsb-release \
    && rm -rf /var/lib/apt/lists/*

# Switch to jovyan user
USER jovyan

# Expose the notebook port
EXPOSE 8888

# Start the notebook
CMD ["start-notebook.sh"]
