# Step 1: Base image setup
FROM mcr.microsoft.com/dotnet/core/sdk:3.1 AS base

# Step 2: Update and install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    gnupg \
    lsb-release \
    apt-transport-https \
    software-properties-common \
    libssl-dev \
    libicu-dev \
    unzip \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Step 3: Install .NET Core 3.1 runtime manually
RUN wget https://download.visualstudio.microsoft.com/download/pr/ff4f37d9-3b45-4d57-bbd5-dc57e1b2b38d/404e772be1c0f4189fbb65efadfe9ed1/dotnet-runtime-3.1.32-linux-x64.tar.gz -O /tmp/dotnet-runtime-3.1.32-linux-x64.tar.gz \
    && mkdir -p /usr/share/dotnet \
    && tar -xzf /tmp/dotnet-runtime-3.1.32-linux-x64.tar.gz -C /usr/share/dotnet \
    && rm /tmp/dotnet-runtime-3.1.32-linux-x64.tar.gz

# Step 4: Install .NET Interactive globally
RUN dotnet tool install --global Microsoft.dotnet-interactive --version 1.0.155302 --add-source "https://dotnet.myget.org/F/dotnet-try/api/v3/index.json" --tool-path /usr/local/.dotnet/tools

# Step 5: Install Jupyter for .NET interactive
RUN /usr/local/.dotnet/tools/dotnet-interactive jupyter install

# Step 6: Set environment variables
ENV PATH="${PATH}:/usr/local/.dotnet/tools"

# Step 7: Install required Python packages (for Jupyter compatibility)
RUN apt-get update && apt-get install -y \
    python3-pip \
    python3-dev \
    && rm -rf /var/lib/apt/lists/*

# Step 8: Install Jupyter Notebook
RUN pip3 install --no-cache-dir jupyter

# Step 9: Expose port for Jupyter Notebook
EXPOSE 8888

# Step 10: Start Jupyter Notebook with .NET interactive support
CMD ["jupyter", "notebook", "--ip=0.0.0.0", "--allow-root", "--NotebookApp.token=''", "--NotebookApp.password=''"]
