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
    git \
    sudo \
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

# Step 9: Set correct permissions and ownership for dotnet
RUN chmod -R 755 /usr/share/dotnet && chown -R jovyan:users /usr/share/dotnet

# Step 10: Switch to jovyan user for dotnet tool installation
USER jovyan

# Step 11: Install .NET Interactive tool
RUN /usr/share/dotnet/dotnet tool install --global Microsoft.dotnet-interactive --version 1.0.155302

# Step 12: Add .dotnet/tools to PATH for jovyan user
ENV PATH="/home/jovyan/.dotnet/tools:${PATH}"

# Step 13: Ensure dotnet-interactive is installed
RUN /home/jovyan/.dotnet/tools/dotnet-interactive --version

# Step 14: Install the .NET Interactive kernels (including PowerShell)
RUN /home/jovyan/.dotnet/tools/dotnet-interactive jupyter install

# Step 15: Set the working directory
WORKDIR /home/jovyan

# Step 16: Copy configuration files and notebooks with correct ownership
COPY --chown=jovyan:users ./config /home/jovyan/.jupyter/
COPY --chown=jovyan:users ./ /home/jovyan/WindowsPowerShell/
COPY --chown=jovyan:users ./NuGet.config /home/jovyan/nuget.config

# Step 17: Ensure permissions for .dotnet/tools directory
RUN mkdir -p /home/jovyan/.dotnet/tools && \
    chmod -R 755 /home/jovyan/.dotnet && \
    chown -R jovyan:users /home/jovyan/.dotnet

# Step 18: Install nteract for Jupyter
RUN python3 -m pip install nteract_on_jupyter

# Step 19: Enable telemetry
ENV DOTNET_TRY_CLI_TELEMETRY_OPTOUT=false

# Step 20: Install JupyterLab git extension using pip as root
USER root
RUN python3 -m pip install jupyterlab-git

# Step 21: Install JupyterLab GitHub extension using pip as root
RUN python3 -m pip install jupyterlab_github

# Step 22: Add Microsoft repository and install PowerShell
RUN wget https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb && \
    dpkg -i packages-microsoft-prod.deb && \
    apt-get update && \
    apt-get install -y powershell

# Step 23: Set permissions for dotnet commands
RUN chmod -R 755 /usr/share/dotnet && chown -R jovyan:users /usr/share/dotnet

# Step 24: Add jovyan to sudoers
RUN echo "jovyan ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Step 25: Switch back to jovyan user
USER jovyan

# Step 26: Test dotnet command
RUN sudo dotnet --info

# Step 27: Final working directory
WORKDIR /home/jovyan/WindowsPowerShell/
