FROM python:3.9-slim

LABEL maintainer="tu@email.com"
LABEL description="pygeoapi server with Amazonas data"

# Instalar dependencias del sistema
RUN apt-get update && apt-get install -y \
    gdal-bin \
    libgdal-dev \
    libsqlite3-mod-spatialite \
    python3-gdal \
    curl \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Crear directorio de trabajo
WORKDIR /app

# Configurar variables de entorno para GDAL
ENV CPLUS_INCLUDE_PATH=/usr/include/gdal
ENV C_INCLUDE_PATH=/usr/include/gdal

# Copiar requirements
COPY requirements.txt .

# Instalar dependencias de Python
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Copiar archivos del proyecto
COPY config/ ./config/
COPY datos/ ./datos/
COPY *.sh ./
COPY *.py ./

# Crear directorio de logs
RUN mkdir -p logs

# Variables de entorno
ENV PYGEOAPI_CONFIG=config/pygeoapi-config.yml
ENV PYGEOAPI_OPENAPI=config/openapi.yml

# Generar OpenAPI
RUN pygeoapi openapi generate $PYGEOAPI_CONFIG > $PYGEOAPI_OPENAPI

# Exponer puerto
EXPOSE 5000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
  CMD curl -f http://localhost:5000/ || exit 1

# Comando de inicio
CMD ["gunicorn", "pygeoapi.flask_app:APP", \
     "--bind", "0.0.0.0:5000", \
     "--workers", "4", \
     "--timeout", "30", \
     "--access-logfile", "logs/access.log", \
     "--error-logfile", "logs/error.log"]
