# Step 1: Start from the official .NET SDK image
FROM mcr.microsoft.com/dotnet/sdk:6.0 AS dotnet

# Step 2: Create a new base image from the Jupyter base-notebook
FROM jupyter/base-notebook:latest

# Step 3: Switch to root user to install additional dependencies
USER root

# Step 4: Clear Docker cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Step 5: Install required packages, n package manager, and Node.js
RUN apt-get update && apt-get install -y \
    python3-pip \
    python3-dev \
    curl \
    libicu-dev \
    build-essential \
    wget \
    libssl-dev \
    && curl -L https://raw.githubusercontent.com/tj/n/master/bin/n -o /usr/local/bin/n \
    && chmod +x /usr/local/bin/n \
    && n 14.17.0 \
    && python3 -m pip install --upgrade pip \
    && python3 -m pip install notebook numpy spotipy scipy matplotlib ipython jupyter pandas sympy nose

# Step 6: Install JupyterLab separately to avoid memory issues
RUN python3 -m pip install jupyterlab

# Step 7: Install .NET Runtime 3.1 using the official installation script
RUN curl -SL https://dot.net/v1/dotnet-install.sh | bash /dev/stdin --channel 3.1 --install-dir /usr/share/dotnet

# Step 8: Install .NET Runtime 6.0 using the official installation script
RUN curl -SL https://dot.net/v1/dotnet-install.sh | bash /dev/stdin --channel 6.0 --install-dir /usr/share/dotnet

# Step 9: Install .NET Interactive tool
RUN /usr/share/dotnet/dotnet tool install --global Microsoft.dotnet-interactive --version 1.0.155302

# Step 10: Set PATH to include .dotnet/tools
ENV PATH="$PATH:/root/.dotnet/tools:/home/jovyan/.dotnet/tools"

# Step 11: Ensure dotnet-interactive is installed
RUN dotnet-interactive --version

# Step 12: Install the .NET Interactive kernels (including PowerShell)
RUN dotnet-interactive jupyter install

# Step 13: Set the working directory
WORKDIR /home/jovyan

# Step 14: Copy configuration files and notebooks
COPY ./config /home/jovyan/.jupyter/
COPY ./ /home/jovyan/WindowsPowerShell/
COPY ./NuGet.config /home/jovyan/nuget.config

# Step 15: Change ownership to jovyan user
RUN chown -R jovyan:users /home/jovyan

# Step 16: Install nteract for Jupyter
RUN python3 -m pip install --user nteract_on_jupyter

# Step 17: Switch back to jovyan user
USER jovyan

# Step 18: Enable telemetry
ENV DOTNET_TRY_CLI_TELEMETRY_OPTOUT=false

# Step 19: Install JupyterLab git extension using pip with --user option
RUN pip install --user jupyterlab-git

# Step 20: Install JupyterLab GitHub extension using pip with --user option
RUN pip install --user jupyterlab_github

# Step 21: Switch back to root user
USER root

# Step 22: Ensure apt-get commands run with the proper permissions and install PowerShell
RUN apt-get update && apt-get install -y powershell

# Step 23: Final working directory
WORKDIR /home/jovyan/WindowsPowerShell/
