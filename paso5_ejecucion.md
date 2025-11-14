# Paso 5: Ejecución del Servicio

Este paso cubre cómo iniciar y ejecutar el servidor pygeoapi.

## Prerequisitos

- Haber completado todos los pasos anteriores (1-4)
- Tener la configuración validada
- Entorno virtual activado

## 1. Métodos de Ejecución

### Método 1: Servidor de Desarrollo (Recomendado para pruebas)

El servidor de desarrollo es ideal para pruebas locales y desarrollo:

```bash
# Activar entorno virtual
source venv/bin/activate

# Configurar variables de entorno
export PYGEOAPI_CONFIG=config/pygeoapi-config.yml
export PYGEOAPI_OPENAPI=config/openapi.yml

# Generar OpenAPI
pygeoapi openapi generate $PYGEOAPI_CONFIG > $PYGEOAPI_OPENAPI

# Iniciar servidor
pygeoapi serve
```

El servidor estará disponible en: http://localhost:5000

### Método 2: Gunicorn (Recomendado para producción)

Para producción, usa Gunicorn con múltiples workers:

```bash
# Activar entorno virtual
source venv/bin/activate

# Configurar variables de entorno
export PYGEOAPI_CONFIG=config/pygeoapi-config.yml
export PYGEOAPI_OPENAPI=config/openapi.yml

# Generar OpenAPI
pygeoapi openapi generate $PYGEOAPI_CONFIG > $PYGEOAPI_OPENAPI

# Iniciar con Gunicorn
gunicorn pygeoapi.flask_app:APP \
    --bind 0.0.0.0:5000 \
    --workers 4 \
    --worker-class sync \
    --timeout 30 \
    --access-logfile logs/access.log \
    --error-logfile logs/error.log \
    --log-level info
```

### Método 3: Con Recarga Automática (Desarrollo)

Para desarrollo con recarga automática:

```bash
export PYGEOAPI_CONFIG=config/pygeoapi-config.yml
export PYGEOAPI_OPENAPI=config/openapi.yml

pygeoapi openapi generate $PYGEOAPI_CONFIG > $PYGEOAPI_OPENAPI

# Con Flask (modo debug)
FLASK_APP=pygeoapi.flask_app:APP flask run --reload --port 5000
```

## 2. Scripts de Inicio

### Script Principal: start.sh

```bash
#!/bin/bash

echo "=== Iniciando pygeoapi ==="
echo ""

# Verificar directorio
if [ ! -f "config/pygeoapi-config.yml" ]; then
    echo "ERROR: No se encuentra config/pygeoapi-config.yml"
    echo "Asegúrate de estar en el directorio raíz del proyecto"
    exit 1
fi

# Activar entorno virtual
if [ -z "$VIRTUAL_ENV" ]; then
    if [ -d "venv" ]; then
        echo "Activando entorno virtual..."
        source venv/bin/activate
    else
        echo "ERROR: No se encuentra el entorno virtual"
        exit 1
    fi
fi

# Configurar variables de entorno
export PYGEOAPI_CONFIG=config/pygeoapi-config.yml
export PYGEOAPI_OPENAPI=config/openapi.yml

echo "Configuración: $PYGEOAPI_CONFIG"
echo ""

# Validar configuración
echo "Validando configuración..."
if ! pygeoapi config validate $PYGEOAPI_CONFIG; then
    echo "ERROR: Configuración no válida"
    exit 1
fi
echo "✓ Configuración válida"
echo ""

# Generar OpenAPI
echo "Generando especificación OpenAPI..."
pygeoapi openapi generate $PYGEOAPI_CONFIG > $PYGEOAPI_OPENAPI
echo "✓ OpenAPI generado"
echo ""

# Iniciar servidor
echo "========================================"
echo "Iniciando servidor pygeoapi"
echo "URL: http://localhost:5000"
echo "========================================"
echo ""
echo "Presiona Ctrl+C para detener el servidor"
echo ""

pygeoapi serve
```

### Script para Producción: start_production.sh

```bash
#!/bin/bash

echo "=== Iniciando pygeoapi (Producción) ==="
echo ""

# Verificar directorio
if [ ! -f "config/pygeoapi-config.yml" ]; then
    echo "ERROR: No se encuentra config/pygeoapi-config.yml"
    exit 1
fi

# Activar entorno virtual
if [ -z "$VIRTUAL_ENV" ]; then
    if [ -d "venv" ]; then
        source venv/bin/activate
    else
        echo "ERROR: No se encuentra el entorno virtual"
        exit 1
    fi
fi

# Configurar variables de entorno
export PYGEOAPI_CONFIG=config/pygeoapi-config.yml
export PYGEOAPI_OPENAPI=config/openapi.yml

# Validar y generar OpenAPI
pygeoapi config validate $PYGEOAPI_CONFIG || exit 1
pygeoapi openapi generate $PYGEOAPI_CONFIG > $PYGEOAPI_OPENAPI

# Número de workers (CPU cores * 2 + 1)
WORKERS=$(( $(nproc) * 2 + 1 ))

echo "Iniciando Gunicorn con $WORKERS workers..."
echo "URL: http://localhost:5000"
echo ""

gunicorn pygeoapi.flask_app:APP \
    --bind 0.0.0.0:5000 \
    --workers $WORKERS \
    --worker-class sync \
    --timeout 30 \
    --max-requests 1000 \
    --max-requests-jitter 50 \
    --access-logfile logs/access.log \
    --error-logfile logs/error.log \
    --log-level info \
    --pid gunicorn.pid \
    --daemon

if [ $? -eq 0 ]; then
    echo "✓ Servidor iniciado en segundo plano"
    echo "PID guardado en gunicorn.pid"
    echo ""
    echo "Para detener el servidor:"
    echo "  ./stop.sh"
    echo ""
    echo "Para ver los logs:"
    echo "  tail -f logs/access.log"
    echo "  tail -f logs/error.log"
else
    echo "✗ Error al iniciar el servidor"
    exit 1
fi
```

### Script para Detener: stop.sh

```bash
#!/bin/bash

echo "=== Deteniendo pygeoapi ==="

if [ -f "gunicorn.pid" ]; then
    PID=$(cat gunicorn.pid)
    echo "Deteniendo proceso $PID..."

    if kill -0 $PID 2>/dev/null; then
        kill $PID
        echo "✓ Servidor detenido"
        rm gunicorn.pid
    else
        echo "⚠ El proceso ya no está ejecutándose"
        rm gunicorn.pid
    fi
else
    echo "⚠ No se encuentra gunicorn.pid"
    echo "Buscando procesos de pygeoapi..."

    # Buscar y matar procesos de gunicorn
    PIDS=$(pgrep -f "gunicorn.*pygeoapi")
    if [ -n "$PIDS" ]; then
        echo "Deteniendo procesos: $PIDS"
        kill $PIDS
        echo "✓ Procesos detenidos"
    else
        echo "No se encontraron procesos de pygeoapi ejecutándose"
    fi
fi
```

## 3. Configuración Systemd (Linux)

Para ejecutar pygeoapi como servicio del sistema:

### Crear archivo de servicio: /etc/systemd/system/pygeoapi.service

```ini
[Unit]
Description=pygeoapi OGC API service
After=network.target

[Service]
Type=simple
User=tu_usuario
Group=tu_grupo
WorkingDirectory=/ruta/a/Servicios_SIG_con_Python
Environment="PATH=/ruta/a/Servicios_SIG_con_Python/venv/bin"
Environment="PYGEOAPI_CONFIG=/ruta/a/Servicios_SIG_con_Python/config/pygeoapi-config.yml"
Environment="PYGEOAPI_OPENAPI=/ruta/a/Servicios_SIG_con_Python/config/openapi.yml"
ExecStartPre=/ruta/a/Servicios_SIG_con_Python/venv/bin/pygeoapi openapi generate ${PYGEOAPI_CONFIG}
ExecStart=/ruta/a/Servicios_SIG_con_Python/venv/bin/gunicorn \
    pygeoapi.flask_app:APP \
    --bind 0.0.0.0:5000 \
    --workers 4 \
    --timeout 30 \
    --access-logfile /ruta/a/Servicios_SIG_con_Python/logs/access.log \
    --error-logfile /ruta/a/Servicios_SIG_con_Python/logs/error.log
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

### Comandos del servicio:

```bash
# Habilitar el servicio
sudo systemctl enable pygeoapi

# Iniciar el servicio
sudo systemctl start pygeoapi

# Ver estado
sudo systemctl status pygeoapi

# Detener el servicio
sudo systemctl stop pygeoapi

# Reiniciar el servicio
sudo systemctl restart pygeoapi

# Ver logs
sudo journalctl -u pygeoapi -f
```

## 4. Configuración con Docker (Opcional)

### Dockerfile

```dockerfile
FROM python:3.9-slim

# Instalar dependencias del sistema
RUN apt-get update && apt-get install -y \
    gdal-bin \
    libgdal-dev \
    && rm -rf /var/lib/apt/lists/*

# Crear directorio de trabajo
WORKDIR /app

# Copiar archivos
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

# Variables de entorno
ENV PYGEOAPI_CONFIG=config/pygeoapi-config.yml
ENV PYGEOAPI_OPENAPI=config/openapi.yml

# Generar OpenAPI
RUN pygeoapi openapi generate $PYGEOAPI_CONFIG > $PYGEOAPI_OPENAPI

# Exponer puerto
EXPOSE 5000

# Comando de inicio
CMD ["gunicorn", "pygeoapi.flask_app:APP", \
     "--bind", "0.0.0.0:5000", \
     "--workers", "4", \
     "--timeout", "30"]
```

### docker-compose.yml

```yaml
version: '3.8'

services:
  pygeoapi:
    build: .
    ports:
      - "5000:5000"
    volumes:
      - ./config:/app/config
      - ./datos:/app/datos
      - ./logs:/app/logs
    environment:
      - PYGEOAPI_CONFIG=config/pygeoapi-config.yml
      - PYGEOAPI_OPENAPI=config/openapi.yml
    restart: unless-stopped
```

## 5. Verificación Rápida

Una vez iniciado el servidor, verifica que funciona:

```bash
# Verificar que el servidor responde
curl http://localhost:5000/

# Verificar colecciones
curl http://localhost:5000/collections

# Verificar colección amazonas
curl http://localhost:5000/collections/amazonas
```

## 6. Acceso desde el Navegador

Abre tu navegador y accede a:

- **Landing Page:** http://localhost:5000
- **Documentación API:** http://localhost:5000/openapi?f=html
- **Colecciones:** http://localhost:5000/collections
- **Amazonas:** http://localhost:5000/collections/amazonas
- **Items:** http://localhost:5000/collections/amazonas/items

## Solución de Problemas

### Error: Port 5000 already in use

```bash
# Ver qué proceso usa el puerto
lsof -i :5000

# Matar el proceso
kill -9 <PID>

# O cambiar el puerto en config/pygeoapi-config.yml
```

### Error: Cannot import name 'APP'

```bash
# Reinstalar pygeoapi
pip uninstall pygeoapi
pip install pygeoapi

# Verificar instalación
pip show pygeoapi
```

### Error: Configuration file not found

```bash
# Verificar variables de entorno
echo $PYGEOAPI_CONFIG
echo $PYGEOAPI_OPENAPI

# Establecer correctamente
export PYGEOAPI_CONFIG=config/pygeoapi-config.yml
export PYGEOAPI_OPENAPI=config/openapi.yml
```

### El servidor se detiene inesperadamente

Revisa los logs:
```bash
tail -f logs/pygeoapi.log
tail -f logs/error.log
```

## Siguiente Paso

Una vez que el servidor está ejecutándose, continúa con:
- **Paso 6:** Pruebas y verificación (rama `feature_step_6`)

## Checklist de Verificación

- [ ] Entorno virtual activado
- [ ] Variables de entorno configuradas
- [ ] Configuración validada
- [ ] OpenAPI generado
- [ ] Servidor iniciado correctamente
- [ ] Landing page accesible (http://localhost:5000)
- [ ] Colecciones accesibles
- [ ] Sin errores en logs

---

**Referencia:** Ver [SETUP_GUIDE.md](SETUP_GUIDE.md) para la guía completa.
