# Step 1: Start from the Jupyter base-notebook image
FROM jupyter/base-notebook:latest

# Step 2: Set environment variables to extend timeout settings
ENV JUPYTERLAB_TIMEOUT 1200

# Step 3: Switch to root user to install additional dependencies
USER root

# Step 4: Clear Docker cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Step 5: Install required packages and dependencies
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    sudo

# Step 6: Switch to jovyan user
USER jovyan

# Step 7: Set working directory
WORKDIR /home/jovyan

# Step 8: Ensure permissions for working directory
RUN mkdir -p /home/jovyan/.jupyter && \
    chmod -R 755 /home/jovyan/.jupyter && \
    chown -R jovyan:users /home/jovyan/.jupyter

# Step 9: Add logging configuration
RUN echo "c.NotebookApp.log_level = 'DEBUG'" > /home/jovyan/.jupyter/jupyter_notebook_config.py && \
    echo "c.NotebookApp.log_file = '/home/jovyan/.jupyter/jupyter.log'" >> /home/jovyan/.jupyter/jupyter_notebook_config.py && \
    echo "c.NotebookApp.ip = '0.0.0.0'" >> /home/jovyan/.jupyter/jupyter_notebook_config.py && \
    echo "c.NotebookApp.open_browser = False" >> /home/jovyan/.jupyter/jupyter_notebook_config.py

# Step 10: Run Jupyter Notebook with detailed logging and extended timeout
CMD jupyter notebook --allow-root --no-browser --ip=0.0.0.0 --port=8888 --NotebookApp.log_level=DEBUG --NotebookApp.shutdown_no_activity_timeout=1200 --MappingKernelManager.cull_interval=1200 --MappingKernelManager.cull_idle_timeout=1200
