FROM jupyter/base-notebook:latest

# Install necessary packages and libraries
RUN apt-get update && apt-get install -y \
    curl \
    libssl-dev \
    libicu-dev \
    libssl3 \
    gnupg \
    lsb-release \
    && rm -rf /var/lib/apt/lists/*

# Install .NET SDK
RUN dotnet_sdk_version=3.1.301 \
    && curl -SL --output dotnet.tar.gz https://dotnetcli.azureedge.net/dotnet/Sdk/$dotnet_sdk_version/dotnet-sdk-$dotnet_sdk_version-linux-x64.tar.gz \
    && dotnet_sha512='dd39931df438b8c1561f9a3bdb50f72372e29e5706d3fb4c490692f04a3d55f5acc0b46b8049bc7ea34dedba63c71b4c64c57032740cbea81eef1dce41929b4e' \
    && echo "$dotnet_sha512 dotnet.tar.gz" | sha512sum -c - \
    && mkdir -p /usr/share/dotnet \
    && tar -ozxf dotnet.tar.gz -C /usr/share/dotnet \
    && rm dotnet.tar.gz \
    && ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet \
    # Trigger first run experience by running arbitrary cmd
    && dotnet help

# Install Microsoft .NET Interactive CLI tool
RUN dotnet tool install --global Microsoft.dotnet-interactive --version 1.0.155302 --add-source "https://dotnet.myget.org/F/dotnet-try/api/v3/index.json"

# Install nteract on Jupyter
RUN pip install nteract_on_jupyter

# Install other Python dependencies
COPY requirements.txt ./requirements.txt
RUN pip install --upgrade pip
RUN pip install -r requirements.txt

# Copy notebook config and work directory
COPY ./config ${HOME}/.jupyter/
COPY ./ ${HOME}/Notebooks/

# Set working directory and user permissions
USER root
RUN chown -R jovyan ${HOME}
USER jovyan

WORKDIR ${HOME}/Notebooks/

# Build Jupyter Lab
RUN jupyter lab build

# Install JupyterLab extensions
RUN jupyter labextension install @jupyterlab/git
RUN jupyter labextension install jupyterlab-github

# Additional configurations
ENV DOTNET_RUNNING_IN_CONTAINER=true \
    DOTNET_USE_POLLING_FILE_WATCHER=true \
    NUGET_XMLDOC_MODE=skip \
    DOTNET_TRY_CLI_TELEMETRY_OPTOUT=true

# Final setup (running as jovyan)
USER jovyan

# Set up environment variables for .NET Core usage
ENV PATH="${PATH}:${HOME}/.dotnet/tools"
RUN echo "$PATH"
RUN dotnet interactive jupyter install

