FROM geopython/pygeoapi:latest

LABEL maintainer="tu@email.com"
LABEL description="pygeoapi server with Amazonas data"

# Copiar archivos de configuración y datos
COPY config/pygeoapi-config.yml /pygeoapi/local.config.yml
COPY datos/ /data/

# Variables de entorno
ENV PYGEOAPI_CONFIG=/pygeoapi/local.config.yml
ENV PYGEOAPI_OPENAPI=/pygeoapi/local.openapi.yml

# Exponer puerto
EXPOSE 5000
