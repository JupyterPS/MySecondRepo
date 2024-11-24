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

# Step 10: Create symbolic links to make dotnet commands available
RUN ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet

# Step 11: Switch to jovyan user for dotnet tool installation
USER jovyan

# Step 12: Install .NET Interactive tool
RUN /usr/share/dotnet/dotnet tool install --global Microsoft.dotnet-interactive --version 1.0.155302

# Step 13: Add .dotnet/tools to PATH for jovyan user
ENV PATH="/home/jovyan/.dotnet/tools:/usr/share/dotnet:${PATH}"

# Step 14: Verify dotnet and dotnet-interactive installations
RUN echo $PATH
RUN ls -la /home/jovyan/.dotnet/tools
RUN ls -la /usr/share/dotnet
RUN dotnet --info
RUN dotnet-interactive --version

# Step 15: Install the .NET Interactive kernels (including PowerShell)
RUN dotnet-interactive jupyter install

# Step 16: Install PowerShell kernel
RUN pip install powershell_kernel
RUN python -m powershell_kernel.install

# Step 17: Set the working directory
WORKDIR /home/jovyan

# Step 18: Copy configuration files and notebooks with correct ownership
COPY --chown=jovyan:users ./config /home/jovyan/.jupyter/
COPY --chown=jovyan:users ./ /home/jovyan/WindowsPowerShell/
COPY --chown=jovyan:users ./NuGet.config /home/jovyan/nuget.config

# Step 19: Ensure permissions for .dotnet/tools directory
RUN mkdir -p /home/jovyan/.dotnet/tools && \
    chmod -R 755 /home/jovyan/.dotnet && \
    chown -R jovyan:users /home/jovyan/.dotnet

# Step 20: Install nteract for Jupyter
USER root
RUN python3 -m pip install nteract_on_jupyter

# Step 21: Enable telemetry
ENV DOTNET_TRY_CLI_TELEMETRY_OPTOUT=false

# Step 22: Install JupyterLab git extension using pip as root
RUN python3 -m pip install jupyterlab-git

# Step 23: Install JupyterLab GitHub extension using pip as root
RUN python3 -m pip install jupyterlab_github

# Step 24: Add Microsoft repository and install PowerShell
RUN wget https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb && \
    dpkg -i packages-microsoft-prod.deb && \
    apt-get update && \
    apt-get install -y powershell

# Step 25: Add jovyan to sudoers
RUN echo "jovyan ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Step 26: Switch back to jovyan user
USER jovyan

# Step 27: Test dotnet command
RUN sudo dotnet --info

# Step 28: Final working directory
WORKDIR /home/jovyan/WindowsPowerShell/

# Step 29: Add logging configuration and extended timeout
RUN mkdir -p /home/jovyan/.jupyter && \
    echo "c.NotebookApp.log_level = 'DEBUG'" > /home/jovyan/.jupyter/jupyter_notebook_config.py && \
    echo "c.NotebookApp.log_file = '/home/jovyan/.jupyter/jupyter.log'" >> /home/jovyan/.jupyter/jupyter_notebook_config.py && \
    echo "c.NotebookApp.ip = '0.0.0.0'" >> /home/jovyan/.jupyter/jupyter_notebook_config.py && \
    echo "c.NotebookApp.open_browser = False" >> /home/jovyan/.jupyter/jupyter_notebook_config.py && \
    echo "c.NotebookApp.shutdown_no_activity_timeout = 600" >> /home/jovyan/.jupyter/jupyter_notebook_config.py && \
    echo "c.MappingKernelManager.cull_interval = 600" >> /home/jovyan/.jupyter/jupyter_notebook_config.py && \
    echo "c.MappingKernelManager.cull_idle_timeout = 600" >> /home/jovyan/.jupyter/jupyter_notebook_config.py

# Step 30: Add a command to view logs after start
CMD tail -f /home/jovyan/.jupyter/jupyter.log

# Step 31: Run Jupyter Notebook and ensure logs capture kernel activity
CMD jupyter notebook --allow-root --no-browser --ip=0.0.0.0 --port=8888 --NotebookApp.log_level=DEBUG --NotebookApp.log_file=/home/jovyan/.jupyter/jupyter.log
