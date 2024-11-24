# Start from the official .NET SDK image
FROM mcr.microsoft.com/dotnet/sdk:6.0 AS dotnet

# Create a new base image from the Jupyter base-notebook
FROM jupyter/base-notebook:latest

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
    apt-utils \
    && curl -L https://raw.githubusercontent.com/tj/n/master/bin/n -o /usr/local/bin/n \
    && chmod +x /usr/local/bin/n \
    && n 14.17.0 \
    && python3 -m pip install --upgrade pip \
    && python3 -m pip install notebook numpy spotipy scipy matplotlib ipython jupyter pandas sympy nose \
    && chown -R jovyan:users /home/jovyan/.cache

# Install JupyterLab separately to avoid memory issues
RUN python3 -m pip install jupyterlab

# Install .NET Runtime 3.1 using the official installation script
RUN curl -SL https://dot.net/v1/dotnet-install.sh | bash /dev/stdin --channel 3.1 --install-dir /usr/share/dotnet

# Install .NET Runtime 6.0 using the official installation script
RUN curl -SL https://dot.net/v1/dotnet-install.sh | bash /dev/stdin --channel 6.0 --install-dir /usr/share/dotnet

# Set correct permissions and ownership for dotnet
RUN chmod -R 755 /usr/share/dotnet && chown -R jovyan:users /usr/share/dotnet

# Create symbolic links to make dotnet commands available
RUN ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet

# Switch to jovyan user for dotnet tool installation
USER jovyan

# Install .NET Interactive tool
RUN /usr/share/dotnet/dotnet tool install --global Microsoft.dotnet-interactive --version 1.0.155302

# Add .dotnet/tools to PATH for jovyan user
ENV PATH="/home/jovyan/.dotnet/tools:/usr/share/dotnet:${PATH}"

# Verify dotnet and dotnet-interactive installations
RUN echo $PATH
RUN ls -la /home/jovyan/.dotnet/tools
RUN ls -la /usr/share/dotnet
RUN dotnet --info
RUN dotnet-interactive --version

# Install the .NET Interactive kernels (including PowerShell)
RUN dotnet-interactive jupyter install

# Set the working directory
WORKDIR /home/jovyan

# Copy configuration files and notebooks with correct ownership
COPY --chown=jovyan:users ./config /home/jovyan/.jupyter/
COPY --chown=jovyan:users ./ /home/jovyan/WindowsPowerShell/
COPY --chown=jovyan:users ./NuGet.config /home/jovyan/nuget.config

# Ensure permissions for .dotnet/tools directory
RUN mkdir -p /home/jovyan/.dotnet/tools && \
    chmod -R 755 /home/jovyan/.dotnet && \
    chown -R jovyan:users /home/jovyan/.dotnet

# Install nteract for Jupyter
RUN python3 -m pip install nteract_on_jupyter

# Enable telemetry
ENV DOTNET_TRY_CLI_TELEMETRY_OPTOUT=false

# Install JupyterLab git extension using pip as root
USER root
RUN python3 -m pip install jupyterlab-git

# Install JupyterLab GitHub extension using pip as root
RUN python3 -m pip install jupyterlab_github

# Add Microsoft repository and install PowerShell
RUN wget https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb && \
    dpkg -i packages-microsoft-prod.deb && \
    apt-get update && \
    apt-get install -y powershell

# Add jovyan to sudoers
RUN echo "jovyan ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Switch back to jovyan user
USER jovyan

# Test dotnet command
RUN sudo dotnet --info

# Final working directory
WORKDIR /home/jovyan/WindowsPowerShell/

# Add logging configuration
RUN mkdir -p /home/jovyan/.jupyter && \
    echo "c.NotebookApp.log_level = 'DEBUG'" > /home/jovyan/.jupyter/jupyter_notebook_config.py && \
    echo "c.NotebookApp.log_file = '/home/jovyan/.jupyter/jupyter.log'" >> /home/jovyan/.jupyter/jupyter_notebook_config.py && \
    echo "c.NotebookApp.ip = '0.0.0.0'" >> /home/jovyan/.jupyter/jupyter_notebook_config.py && \
    echo "c.NotebookApp.open_browser = False" >> /home/jovyan/.jupyter/jupyter_notebook_config.py

# Run Jupyter and log startup information
CMD jupyter notebook --allow-root --no-browser --ip=0.0.0.0 --port=8888 --log-level=DEBUG
