# Start with the base Jupyter image
FROM jupyter/base-notebook:latest

# Ensure root permissions for system updates and installations
USER root

# Install necessary system dependencies including SSL libraries
RUN apt-get update && apt-get install -y \
    curl \
    libssl-dev \
    libssl3 \
    libicu-dev \
    gnupg \
    lsb-release \
    && rm -rf /var/lib/apt/lists/*

# Install .NET Core SDK dependencies (version 3.1.301)
RUN dotnet_sdk_version=3.1.301 \
    && curl -SL --output dotnet.tar.gz https://dotnetcli.azureedge.net/dotnet/Sdk/$dotnet_sdk_version/dotnet-sdk-$dotnet_sdk_version-linux-x64.tar.gz \
    && dotnet_sha512='dd39931df438b8c1561f9a3bdb50f72372e29e5706d3fb4c490692f04a3d55f5acc0b46b8049bc7ea34dedba63c71b4c64c57032740cbea81eef1dce41929b4e' \
    && echo "$dotnet_sha512 dotnet.tar.gz" | sha512sum -c - \
    && mkdir -p /usr/share/dotnet \
    && tar -ozxf dotnet.tar.gz -C /usr/share/dotnet \
    && rm dotnet.tar.gz \
    && ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet \
    && dotnet --version

# Install .NET interactive tool
RUN dotnet tool install --global Microsoft.dotnet-interactive --version 1.0.155302 --add-source "https://dotnet.myget.org/F/dotnet-try/api/v3/index.json"

# Install additional Python libraries via pip
RUN pip install --no-cache-dir \
    nteract_on_jupyter \
    jupyterlab-git \
    spotipy \
    scipy \
    numpy \
    pandas \
    matplotlib \
    ipython \
    sympy \
    nose

# Install JupyterLab Git extension
RUN jupyter labextension install @jupyterlab/git

# Install .NET Interactive Jupyter kernel
RUN dotnet interactive jupyter install

# Set environment variable for telemetry opt-out (optional)
ENV DOTNET_CLI_TELEMETRY_OPTOUT=true

# Switch to non-root user (jovyan) for security
USER jovyan

# Expose the notebook's port
EXPOSE 8888

# Start the Jupyter notebook server
CMD ["start-notebook.sh"]
