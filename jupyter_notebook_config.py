c = get_config()  # Initialize configuration
c.NotebookApp.ip = '0.0.0.0'
c.NotebookApp.port = 8888
c.NotebookApp.open_browser = False
c.NotebookApp.allow_root = True
c.NotebookApp.token = ''
c.NotebookApp.log_level = 'DEBUG'
c.NotebookApp.log_file = '/home/jovyan/logs/jupyter.log'
