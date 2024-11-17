# Use base image with Jupyter Notebook
FROM jupyter/base-notebook:latest

# Upgrade pip and install dependencies from requirements.txt
RUN python -m pip install --upgrade pip
COPY requirements.txt ./requirements.txt
RUN python -m pip install -r requirements.txt
RUN python -m pip install --upgrade --no-deps --force-reinstall notebook

# Install JupyterLab extensions with versions
RUN python -m pip install jupyterlab_github==0.1.0
RUN python -m pip install jupyterlab-git==0.34.0
RUN jupyter labextension install @jupyterlab/git@^5.0.0

# Install Jupyter themes and contrib nbextensions with versions
RUN python -m pip install jupyterthemes==0.20.0
RUN python -m pip install jupyter_contrib_nbextensions==0.5.1
RUN jupyter contrib nbextension install --user
RUN jupyter nbextension enable codefolding/main
RUN jupyter nbextension enable toc2/main

# Install system dependencies for .NET and PowerShell
RUN apt-get update -S
RUN apt-get install -y libicu66 curl sudo

# Install PowerShell with specific version
RUN curl https://packages.microsoft.com/keys/microsoft.asc | tee /etc/apt/trusted.gpg.d/microsoft.asc
RUN curl https://packages.microsoft.com/config/ubuntu/20.04/prod.list | tee /etc/apt/sources.list.d/microsoft-prod.list
RUN apt-get update
RUN apt-get install -y powershell=7.1.5-1.ubuntu.20.04

# Install .NET CLI dependencies
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        libc6 libgcc1 libgssapi-krb5-2 libicu66 libssl1.1 libstdc++6 zlib1g \
    && rm -rf /var/lib/apt/lists/*

# Install .NET Core SDK with specific version
RUN dotnet_sdk_version=5.0.202 \
    && curl -SL --output dotnet.tar.gz https://dotnetcli.azureedge.net/dotnet/Sdk/$dotnet_sdk_version/dotnet-sdk-$dotnet_sdk_version-linux-x64.tar.gz \
    && dotnet_sha512='your_sha512_checksum' \
    && echo "$dotnet_sha512 dotnet.tar.gz" | sha512sum -c - \
    && mkdir -p /usr/share/dotnet \
    && tar -ozxf dotnet.tar.gz -C /usr/share/dotnet \
    && rm dotnet.tar.gz \
    && ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet

# Install .NET Interactive for Jupyter
RUN dotnet tool install --global Microsoft.dotnet-interactive --version 1.0.155302 --add-source "https://dotnet.myget.org/F/dotnet-try/api/v3/index.json"

# Ensure correct PATH for .NET tools
ENV PATH="${PATH}:${HOME}/.dotnet/tools"

# Ensure necessary directories for Jupyter kernels exist
RUN mkdir -p /root/.local/share/jupyter/kernels/csharp && \
    mkdir -p /root/.local/share/jupyter/kernels/fsharp && \
    mkdir -p /root/.local/share/jupyter/kernels/powershell

# Install Jupyter kernels
RUN dotnet interactive jupyter install

# Copy configuration files and notebooks
COPY ./config ${HOME}/.jupyter/
COPY ./ ${HOME}/Notebooks/
COPY ./NuGet.config ${HOME}/nuget.config

# Set up user
RUN chown -R ${NB_UID} ${HOME}
USER ${USER}

# Install nteract
RUN pip install nteract_on_jupyter==2.1.2

# Set root to Notebooks
WORKDIR ${HOME}/Notebooks/
