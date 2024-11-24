# Step 1: Start from the Jupyter base-notebook image
FROM jupyter/base-notebook:latest

# Step 2: Install necessary dependencies
USER root
RUN apt-get update && apt-get install -y curl wget sudo

# Step 3: Set working directory and permissions
USER jovyan
WORKDIR /home/jovyan
RUN mkdir -p /home/jovyan/.jupyter && chmod -R 755 /home/jovyan/.jupyter && chown -R jovyan:users /home/jovyan/.jupyter

# Step 4: Add logging configuration
RUN echo "c.NotebookApp.log_level = 'DEBUG'" > /home/jovyan/.jupyter/jupyter_notebook_config.py && \
    echo "c.NotebookApp.log_file = '/home/jovyan/.jupyter/jupyter.log'" >> /home/jovyan/.jupyter/jupyter_notebook_config.py && \
    echo "c.NotebookApp.ip = '0.0.0.0'" >> /home/jovyan/.jupyter/jupyter_notebook_config.py && \
    echo "c.NotebookApp.open_browser = False" >> /home/jovyan/.jupyter/jupyter_notebook_config.py && \
    echo "c.NotebookApp.token = ''" >> /home/jovyan/.jupyter/jupyter_notebook_config.py && \
    echo "c.NotebookApp.password = ''" >> /home/jovyan/.jupyter/jupyter_notebook_config.py

# Step 5: Run Jupyter Notebook
CMD ["jupyter", "notebook", "--allow-root", "--no-browser", "--ip=0.0.0.0", "--port=8888"]
