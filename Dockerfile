# Step 1: Start from Jupyter base notebook for the final repository
FROM jupyter/base-notebook:latest

# Step 2: Upgrade pip and install required dependencies from requirements.txt
RUN python -m pip install --upgrade pip
COPY requirements.txt ./requirements.txt
RUN python -m pip install -r requirements.txt
RUN python -m pip install --upgrade --no-deps --force-reinstall notebook 

# Step 3: Install JupyterLab extensions
RUN python -m pip install jupyterlab_github jupyterlab-git

# Step 4: (Remove deprecated command for labextension install)
#RUN jupyter labextension install @jupyterlab/git

# Step 5: Install PowerShell
RUN apt-get update && apt-get install -y powershell 

# Step 6: Update system and install libraries
RUN apt-get update && apt-get install -y libicu66

# Step 7: Install additional Python dependencies
RUN python -m pip install --user numpy spotipy scipy matplotlib ipython jupyter pandas sympy nose

# Step 8: Build JupyterLab
RUN jupyter lab build 

# Step 9: Set user-related environment variables
ARG NB_USER=jovyan
ARG NB_UID=1000
ENV USER ${NB_USER}
ENV NB_UID ${NB_UID}
ENV HOME /home/${NB_USER}

# Step 10: Switch to root user to install additional dependencies
USER root
RUN apt-get update
RUN apt-get install -y curl

# Step 11: Install .NET CLI dependencies
RUN apt-get update && apt-get install -y libicu66

# Step 12: Set environment variables for .NET container setup
ENV \
    DOTNET_RUNNING_IN_CONTAINER=true \
    DOTNET_USE_POLLING_FILE_WATCHER=true \
    NUGET_XMLDOC_MODE=skip \
    DOTNET_TRY_CLI_TELEMETRY_OPTOUT=true

# Step 13: Install .NET CLI dependencies
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        libc6 \
        libgcc1 \
        libgssapi-krb5-2 \
        libicu66 \
        libssl1.1 \
        libstdc++6 \
        zlib1g \
    && rm -rf /var/lib/apt/lists/*

# Step 14: Install .NET Core SDK
RUN dotnet_sdk_version=3.1.301 \
    && curl -SL --output dotnet.tar.gz https://dotnetcli.azureedge.net/dotnet/Sdk/$dotnet_sdk_version/dotnet-sdk-$dotnet_sdk_version-linux-x64.tar.gz \
    && dotnet_sha512='dd39931df438b8c1561f9a3bdb50f72372e29e5706d3fb4c490692f04a3d55f5acc0b46b8049bc7ea34dedba63c71b4c64c57032740cbea81eef1dce41929b4e' \
    && echo "$dotnet_sha512 dotnet.tar.gz" | sha512sum -c - \
    && mkdir -p /usr/share/dotnet \
    && tar -ozxf dotnet.tar.gz -C /usr/share/dotnet \
    && rm dotnet.tar.gz \
    && ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet \
    && dotnet help

# Step 15: Copy notebooks and configuration files
COPY ./config ${HOME}/.jupyter/
COPY ./ ${HOME}/Notebooks/
COPY ./NuGet.config ${HOME}/nuget.config

# Step 16: Change ownership to jovyan user
RUN chown -R ${NB_UID}:${NB_UID} ${HOME}

# Step 17: Switch back to jovyan user
USER ${NB_USER}

# Step 18: Install nteract for Jupyter
RUN pip install nteract_on_jupyter

# Step 19: Install .NET Interactive globally
RUN dotnet tool install --global Microsoft.dotnet-interactive --version 1.0.155302 --add-source "https://dotnet.myget.org/F/dotnet-try/api/v3/index.json"

# Step 20: Update PATH with .NET tools directory
ENV PATH="${PATH}:${HOME}/.dotnet/tools"
RUN echo "$PATH"

# Step 21: Install Jupyter Kernel for .NET Interactive
RUN dotnet interactive jupyter install

# Step 22: Enable telemetry after installing Jupyter
ENV DOTNET_TRY_CLI_TELEMETRY_OPTOUT=false

# Step 23: Set the working directory to Notebooks
WORKDIR ${HOME}/Notebooks/
