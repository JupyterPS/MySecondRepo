FROM jupyter/base-notebook:latest

# Ensure we are running as root
USER root

# Install dependencies, including PowerShell
RUN apt-get update && apt-get install -y \
    curl \
    libssl-dev \
    libicu-dev \
    libssl1.1 \
    gnupg \
    lsb-release \
    && rm -rf /var/lib/apt/lists/*

# Add Microsoft's APT repository for PowerShell
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
RUN curl https://packages.microsoft.com/config/ubuntu/20.04/prod.list > /etc/apt/sources.list.d/microsoft-prod.list

# Install PowerShell
RUN apt-get update && apt-get install -y powershell

# Other installation steps
RUN python -m pip install --upgrade pip
COPY requirements.txt ./requirements.txt
RUN python -m pip install -r requirements.txt
RUN python -m pip install --upgrade --no-deps --force-reinstall notebook 
RUN python -m pip install jupyterlab_github
RUN python -m pip install jupyterlab-git

# Install .NET Core SDK and other dependencies
RUN dotnet_sdk_version=3.1.301 \
    && curl -SL --output dotnet.tar.gz https://dotnetcli.azureedge.net/dotnet/Sdk/$dotnet_sdk_version/dotnet-sdk-$dotnet_sdk_version-linux-x64.tar.gz \
    && dotnet_sha512='dd39931df438b8c1561f9a3bdb50f72372e29e5706d3fb4c490692f04a3d55f5acc0b46b8049bc7ea34dedba63c71b4c64c57032740cbea81eef1dce41929b4e' \
    && echo "$dotnet_sha512 dotnet.tar.gz" | sha512sum -c - \
    && mkdir -p /usr/share/dotnet \
    && tar -ozxf dotnet.tar.gz -C /usr/share/dotnet \
    && rm dotnet.tar.gz \
    && ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet \
    && dotnet help

# Copy notebooks and configuration
COPY ./config ${HOME}/.jupyter/
COPY ./ ${HOME}/Notebooks/
COPY ./NuGet.config ${HOME}/nuget.config

# Install nteract
RUN pip install nteract_on_jupyter

# Install .NET Interactive tools
RUN dotnet tool install --global Microsoft.dotnet-interactive --version 1.0.155302 --add-source "https://dotnet.myget.org/F/dotnet-try/api/v3/index.json"

# Install jupyter lab extensions
RUN jupyter labextension install @jupyterlab/git
RUN jupyter lab build 

# Enable telemetry once we install jupyter for the image
ENV DOTNET_TRY_CLI_TELEMETRY_OPTOUT=false

# Set root to Notebooks
WORKDIR ${HOME}/Notebooks/

# Set the environment variables
ARG NB_USER=jovyan
ARG NB_UID=1000
ENV USER ${NB_USER}
ENV NB_UID ${NB_UID}
ENV HOME /home/${NB_USER}
WORKDIR ${HOME}
USER root
RUN apt-get update && apt-get install -y curl

# Set environment for .NET
ENV \
    DOTNET_RUNNING_IN_CONTAINER=true \
    DOTNET_USE_POLLING_FILE_WATCHER=true \
    NUGET_XMLDOC_MODE=skip \
    DOTNET_TRY_CLI_TELEMETRY_OPTOUT=true

USER ${USER}

# Set working directory
WORKDIR ${HOME}/Notebooks/

