c = get_config()
c.KernelGatewayApp.ip = '0.0.0.0'
c.KernelGatewayApp.port = 8888
c.KernelGatewayApp.allow_origin = '*'
c.KernelGatewayApp.trust_xheaders = True
