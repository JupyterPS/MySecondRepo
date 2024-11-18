# Install .NET 8.0 SDK and runtime
RUN wget https://packages.microsoft.com/config/ubuntu/22.04/prod.list \
    -O /etc/apt/sources.list.d/microsoft-prod.list && \
    curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - && \
    apt-get update && \
    apt-get install -y dotnet-sdk-8.0 dotnet-runtime-8.0

# Install .NET Core 3.1 runtime for compatibility with dotnet-interactive
RUN wget https://download.visualstudio.microsoft.com/download/pr/1a6b7f1c-1b78-4b5c-93c9-1b27d8e8da7f/c1cd27f7c3464f0c2c0a24b96a1a59b5/dotnet-runtime-3.1.32-linux-x64.tar.gz \
    -O /tmp/dotnet-runtime-3.1.32-linux-x64.tar.gz && \
    mkdir -p /usr/share/dotnet && \
    tar -xzf /tmp/dotnet-runtime-3.1.32-linux-x64.tar.gz -C /usr/share/dotnet && \
    rm /tmp/dotnet-runtime-3.1.32-linux-x64.tar.gz
