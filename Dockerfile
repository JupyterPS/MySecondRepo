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

# Step 9: Install .NET Interactive tool
RUN /usr/share/dotnet/dotnet tool install --global Microsoft.dotnet-interactive --version 1.0.155302

# Step 10: Add .dotnet/tools to PATH for both root and jovyan users
ENV PATH="/usr/share/dotnet:/root/.dotnet/tools:/home/jovyan/.dotnet/tools:${PATH}"

# Step 11: List contents of tools directory to debug
RUN ls -la /root/.dotnet/tools
RUN ls -la /home/jovyan/.dotnet/tools

# Step 12: Ensure dotnet-interactive is installed
RUN /root/.dotnet/tools/dotnet-interactive --version || /home/jovyan/.dotnet/tools/dotnet-interactive --version

# Step 13: Install the .NET Interactive kernels (including PowerShell)
RUN /root/.dotnet/tools/dotnet-interactive jupyter install || /home/jovyan/.dotnet/tools/dotnet-interactive jupyter install

# Step 14: Set the working directory
WORKDIR /home/jovyan

# Step 15: Copy configuration files and notebooks with correct ownership
COPY --chown=jovyan:users ./config /home/jovyan/.jupyter/
COPY --chown=jovyan:users ./ /home/jovyan/WindowsPowerShell/
COPY --chown=jovyan:users ./NuGet.config /home/jovyan/nuget.config

# Step 16: Ensure permissions for .dotnet/tools directory
RUN mkdir -p /home/jovyan/.dotnet/tools && \
    chmod -R 755 /home/jovyan/.dotnet && \
    chown -R jovyan:users /home/jovyan/.dotnet

# Step 17: Install nteract for Jupyter
RUN python3 -m pip install nteract_on_jupyter

# Step 18: Enable telemetry
ENV DOTNET_TRY_CLI_TELEMETRY_OPTOUT=false

# Step 19: Install JupyterLab git extension using pip as root
USER root
RUN python3 -m pip install jupyterlab-git

# Step 20: Install JupyterLab GitHub extension using pip as root
RUN python3 -m pip install jupyterlab_github

# Step 21: Add Microsoft repository and install PowerShell
RUN wget https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb && \
    dpkg -i packages-microsoft-prod.deb && \
    apt-get update && \
    apt-get install -y powershell

# Step 22: Set permissions for dotnet commands
RUN chmod -R 755 /usr/share/dotnet && chown -R jovyan:users /usr/share/dotnet

# Step 23: Add jovyan to sudoers
RUN echo "jovyan ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Step 24: Switch back to jovyan user
USER jovyan

# Step 25: Test dotnet command
RUN sudo dotnet --info

# Step 26: Final working directory
WORKDIR /home/jovyan/WindowsPowerShell/
