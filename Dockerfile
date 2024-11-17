# Base image with Jupyter
FROM jupyter/base-notebook:latest

# Switch to root to install system dependencies
USER root

# Update pip and install necessary Python packages
RUN python -m pip install --upgrade pip
COPY requirements.txt ./requirements.txt
RUN python -m pip install -r requirements.txt
RUN python -m pip install --upgrade --no-deps --force-reinstall notebook

# Install JupyterLab extensions
RUN python -m pip install jupyterlab_github
RUN python -m pip install jupyterlab-git
RUN python -m pip install jupyterthemes

# Install required Python libraries
RUN python -m pip install numpy spotipy scipy matplotlib ipython pandas sympy nose

# Install nteract (optional but useful for enhanced Jupyter experience)
RUN pip install nteract_on_jupyter

# Install system dependencies for .NET Core SDK
RUN apt-get update && apt-get install -y curl libicu66

# Install .NET Core SDK
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

# Enable telemetry after installing Jupyter
ENV DOTNET_TRY_CLI_TELEMETRY_OPTOUT=false

# Set the working directory to Notebooks
WORKDIR ${HOME}/Notebooks/

# Set up the necessary environment variables for .NET in the container
ENV \
    DOTNET_RUNNING_IN_CONTAINER=true \
    DOTNET_USE_POLLING_FILE_WATCHER=true \
    NUGET_XMLDOC_MODE=skip \
    DOTNET_TRY_CLI_TELEMETRY_OPTOUT=true

# Copy notebooks and configuration into the container
COPY ./config ${HOME}/.jupyter/
COPY ./ ${HOME}/Notebooks/
COPY ./NuGet.config ${HOME}/nuget.config

# Install JupyterLab Git extension using pip (updated method)
RUN pip install jupyterlab-git

# Rebuild JupyterLab to ensure the Git extension is available
RUN jupyter lab build

# Revert back to jovyan user
USER jovyan

# Expose the correct port for JupyterLab
EXPOSE 8888

# Set the entry point for the container to start JupyterLab
CMD ["start-notebook.sh"]
