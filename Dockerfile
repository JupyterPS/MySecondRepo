# Step 1: Use the official .NET SDK image as the base image
FROM mcr.microsoft.com/dotnet/sdk:6.0 AS dotnet

# Step 2: Create a new base image from the Jupyter base-notebook
FROM jupyter/base-notebook:latest

# Adding a comment to force rebuild
# Updated Dockerfile with necessary steps

# Switch to root user to install additional dependencies
USER root

# Clear Docker cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install required packages, n package manager, and Node.js
RUN apt-get update && apt-get install -y \
    python3-pip \
    python3-dev \
    curl \
    libicu-dev \
    build-essential \
    wget \
    libssl-dev \
    git \
    sudo \
    && curl -L https://raw.githubusercontent.com/tj/n/master/bin/n -o /usr/local/bin/n \
    && chmod +x /usr/local/bin/n \
    && n 14.17.0 \
    && python3 -m pip install --upgrade pip \
    && python3 -m pip install notebook numpy spotipy scipy matplotlib ipython jupyter pandas sympy nose

# Install JupyterLab separately to avoid memory issues
RUN python3 -m pip install jupyterlab

# Install .NET Runtime 3.1 using the official installation script
RUN curl -SL https://dot.net/v1/dotnet-install.sh | bash /dev/stdin --channel 3.1 --install-dir /usr/share/dotnet

# Install .NET Runtime 6.0 using the official installation script
RUN curl -SL https://dot.net/v1/dotnet-install.sh | bash /dev/stdin --channel 6.0 --install-dir /usr/share/dotnet

# Install .NET Interactive tool
RUN /usr/share/dotnet/dotnet tool install --global Microsoft.dotnet-interactive --version 1.0.155302

# Set PATH to include .dotnet/tools
ENV PATH="$PATH:/root/.dotnet/tools:/home/jovyan/.dotnet/tools"

# Ensure dotnet-interactive is installed
RUN dotnet-interactive --version

# Install the .NET Interactive kernels (including PowerShell)
RUN dotnet-interactive jupyter install

# Set the working directory
WORKDIR /home/jovyan

# Copy configuration files and notebooks
COPY ./config /home/jovyan/.jupyter/
COPY ./ /home/jovyan/WindowsPowerShell/
COPY ./NuGet.config /home/jovyan/nuget.config

# Change ownership to jovyan user
RUN chown -R jovyan:users /home/jovyan

# Switch back to jovyan user
USER jovyan

# Enable telemetry
ENV DOTNET_TRY_CLI_TELEMETRY_OPTOUT=false

# Final working directory
WORKDIR /home/jovyan/WindowsPowerShell/

# Add logging configuration and extended timeout
RUN mkdir -p /home/jovyan/.jupyter && \
    echo "c.NotebookApp.log_level = 'DEBUG'" > /home/jovyan/.jupyter/jupyter_notebook_config.py && \
    echo "c.NotebookApp.log_file = '/home/jovyan/.jupyter/jupyter.log'" >> /home/jovyan/.jupyter/jupyter_notebook_config.py && \
    echo "c.NotebookApp.ip = '0.0.0.0'" >> /home/jovyan/.jupyter/jupyter_notebook_config.py && \
    echo "c.NotebookApp.open_browser = False" >> /home/jovyan/.jupyter/jupyter_notebook_config.py && \
    echo "c.NotebookApp.shutdown_no_activity_timeout = 600" >> /home/jovyan/.jupyter/jupyter_notebook_config.py && \
    echo "c.MappingKernelManager.cull_interval = 600" >> /home/jovyan/.jupyter/jupyter_notebook_config.py && \
    echo "c.MappingKernelManager.cull_idle_timeout = 600" >> /home/jovyan/.jupyter/jupyter_notebook_config.py

# Run Jupyter Notebook
CMD jupyter notebook --allow-root --no-browser --ip=0.0.0.0 --port=8888 --NotebookApp.log_level=DEBUG
