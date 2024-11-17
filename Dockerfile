# Base image with Jupyter
FROM jupyter/base-notebook:latest

# Set up environment variables for non-root user
USER root

# Update pip and install necessary Python packages
RUN python -m pip install --upgrade pip

# Install system dependencies (corrected ICU package)
RUN apt-get update && apt-get install -y curl libicu-dev

# Install necessary Python libraries
COPY requirements.txt ./requirements.txt
RUN python -m pip install -r requirements.txt
RUN python -m pip install --upgrade --no-deps --force-reinstall notebook

# Install JupyterLab extensions
RUN python -m pip install jupyterlab_github
RUN python -m pip install jupyterlab-git
RUN python -m pip install jupyterthemes

# Install nteract (optional but useful for enhanced Jupyter experience)
RUN pip install nteract_on_jupyter

# Install .NET Core SDK and .NET Interactive tools
RUN dotnet_sdk_version=3.1.301 \
    && curl -SL --output dotnet.tar.gz https://dotnetcli.azureedge.net/dotnet/Sdk/$dotnet_sdk_version/dotnet-sdk-$dotnet_sdk_version-linux-x64.tar.gz \
    && dotnet_sha512='dd39931df438b8c1561f9a3bdb50f72372e29e5706d3fb4c490692f04a3d55f5acc0b46b8049bc7ea34dedba63c71b4c64c57032740cbea81eef1dce41929b4e' \
    && echo "$dotnet_sha512 dotnet.tar.gz" | sha512sum -c - \
    && mkdir -p /usr/share/dotnet \
    && tar -ozxf dotnet.tar.gz -C /usr/share/dotnet \
    && rm dotnet.tar.gz \
    && ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet

# Install .NET Interactive CLI Tool
RUN dotnet tool install --global Microsoft.dotnet-interactive --version 1.0.155302 --add-source "https://dotnet.myget.org/F/dotnet-try/api/v3/index.json"

# Install Jupyter kernel specs for .NET Interactive
ENV PATH="${PATH}:${HOME}/.dotnet/tools"
RUN dotnet interactive jupyter install

# Install JupyterLab Git extension using pip
RUN pip install jupyterlab-git

# Rebuild JupyterLab to ensure the Git extension is available
RUN jupyter lab build

# Switch back to the jovyan user
USER jovyan

# Expose the correct port for JupyterLab
EXPOSE 8888

# Set the entry point for the container to start JupyterLab
CMD ["start-notebook.sh"]
