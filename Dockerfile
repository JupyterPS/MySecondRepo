FROM jupyter/base-notebook:latest AS base

# Install dependencies and tools
RUN apt-get update && apt-get install -y ... 

# Set up the .NET environment, PowerShell, etc.
RUN dotnet tool install --global Microsoft.dotnet-interactive --version 1.0.155302 

# Set up Jupyter and PowerShell kernel installation
RUN pwsh -Command "Install-Module -Name Jupyter -Force" && \
    pwsh -Command "Install-JupyterKernel"

# Final stage
FROM jupyter/base-notebook:latest

COPY --from=base /root/.dotnet /root/.dotnet

# Set environment variables and path
ENV PATH="/root/.dotnet/tools:$PATH"

# Expose necessary ports
EXPOSE 8888

# Start Jupyter Notebook
CMD ["start-notebook.sh"]
