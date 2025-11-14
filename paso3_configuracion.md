# Paso 3: Configuración Básica

Este paso cubre la creación de la estructura de directorios y el archivo de configuración base para pygeoapi.

## Prerequisitos

- Haber completado el Paso 1 (instalación de dependencias)
- Haber completado el Paso 2 (instalación de pygeoapi)

## 1. Crear Estructura de Directorios

```bash
# Crear directorios necesarios
mkdir -p config
mkdir -p logs

# Verificar estructura
tree -L 1
```

Estructura esperada:
```
.
├── config/          # Archivos de configuración
├── datos/           # Datos geoespaciales (ya existe)
├── logs/            # Archivos de log
├── venv/            # Entorno virtual
└── ...
```

## 2. Crear Archivo de Configuración Base

Crea el archivo `config/pygeoapi-config.yml` con la configuración básica:

```yaml
server:
    bind:
        host: 0.0.0.0
        port: 5000
    url: http://localhost:5000
    mimetype: application/json; charset=UTF-8
    encoding: utf-8
    gzip: false
    languages:
        - es
        - en
    cors: true
    pretty_print: true
    limit: 10
    map:
        url: https://tile.openstreetmap.org/{z}/{x}/{y}.png
        attribution: '&copy; <a href="https://openstreetmap.org/copyright">OpenStreetMap contributors</a>'

logging:
    level: INFO
    logfile: logs/pygeoapi.log

metadata:
    identification:
        title: Servicios SIG con Python - Amazonas
        description: API de servicios geoespaciales para datos del Amazonas
        keywords:
            - geoespacial
            - api
            - amazonas
            - SIG
            - OGC API
        keywords_type: theme
        terms_of_service: https://creativecommons.org/licenses/by/4.0/
        url: http://localhost:5000
    license:
        name: CC-BY 4.0 license
        url: https://creativecommons.org/licenses/by/4.0/
    provider:
        name: Tu Organización
        url: http://localhost:5000
    contact:
        name: Equipo Técnico
        position: Administrador
        address: Dirección
        city: Ciudad
        stateorprovince: Departamento
        postalcode: 000000
        country: Colombia
        phone: +57-xxx-xxx-xxxx
        email: contacto@ejemplo.com
        url: http://localhost:5000

resources: {}
```

## 3. Personalizar la Configuración

### Sección Server

- **bind.host**: Dirección IP del servidor (0.0.0.0 para todas las interfaces)
- **bind.port**: Puerto del servidor (5000 por defecto)
- **url**: URL base del servicio
- **languages**: Idiomas soportados (es, en, etc.)
- **cors**: Habilitar CORS para peticiones cross-origin
- **limit**: Número máximo de features por página

### Sección Logging

- **level**: Nivel de logging (DEBUG, INFO, WARNING, ERROR)
- **logfile**: Ruta al archivo de log

### Sección Metadata

Personaliza la información de tu organización:
- Título y descripción del servicio
- Palabras clave
- Información de contacto
- Licencia

## 4. Validar la Configuración

```bash
# Activar entorno virtual si no está activado
source venv/bin/activate

# Validar el archivo de configuración
pygeoapi config validate config/pygeoapi-config.yml
```

Si todo está correcto, deberías ver:
```
Configuration is valid
```

## 5. Generar Especificación OpenAPI

```bash
pygeoapi openapi generate config/pygeoapi-config.yml > config/openapi.yml
```

Este comando genera la especificación OpenAPI basada en tu configuración.

## 6. Script de Configuración

Para facilitar el proceso, usa este script:

**setup_config.sh:**

```bash
#!/bin/bash

echo "=== Configuración Básica de pygeoapi ==="
echo ""

# Verificar que estamos en el directorio correcto
if [ ! -d "datos" ]; then
    echo "ERROR: No se encuentra el directorio 'datos'"
    echo "Asegúrate de estar en el directorio raíz del proyecto"
    exit 1
fi

# Crear directorios
echo "Creando estructura de directorios..."
mkdir -p config
mkdir -p logs

# Verificar que existe el archivo de configuración
if [ ! -f "config/pygeoapi-config.yml" ]; then
    echo "ERROR: No se encuentra config/pygeoapi-config.yml"
    echo "Por favor, crea el archivo de configuración primero"
    exit 1
fi

# Activar entorno virtual
if [ -z "$VIRTUAL_ENV" ]; then
    echo "Activando entorno virtual..."
    source venv/bin/activate
fi

# Validar configuración
echo ""
echo "Validando configuración..."
if pygeoapi config validate config/pygeoapi-config.yml; then
    echo "✓ Configuración válida"
else
    echo "✗ Error en la configuración"
    exit 1
fi

# Generar OpenAPI
echo ""
echo "Generando especificación OpenAPI..."
pygeoapi openapi generate config/pygeoapi-config.yml > config/openapi.yml
echo "✓ OpenAPI generado en config/openapi.yml"

echo ""
echo "=== Configuración completada exitosamente ==="
echo ""
echo "Archivos creados:"
echo "  config/pygeoapi-config.yml    - Configuración principal"
echo "  config/openapi.yml            - Especificación OpenAPI"
echo "  logs/                         - Directorio de logs"
echo ""
echo "Siguiente paso: Configurar el provider GeoPackage (ver paso4_provider.md)"
```

## 7. Verificar Archivos Creados

```bash
# Verificar estructura
ls -la config/
ls -la logs/

# Ver configuración
cat config/pygeoapi-config.yml

# Ver OpenAPI (primeras líneas)
head -n 20 config/openapi.yml
```

## Solución de Problemas

### Error: Configuration is not valid

Si la configuración no es válida:

1. **Verifica la sintaxis YAML:**
   ```bash
   # Instalar yamllint
   pip install yamllint

   # Validar sintaxis
   yamllint config/pygeoapi-config.yml
   ```

2. **Errores comunes:**
   - Indentación incorrecta (YAML usa espacios, no tabs)
   - Falta de comillas en valores con caracteres especiales
   - Secciones requeridas faltantes

### Error: Permission denied en logs/

```bash
# Ajustar permisos del directorio de logs
chmod 755 logs/
```

### Problema: No se genera el OpenAPI

```bash
# Verificar que la configuración es válida primero
pygeoapi config validate config/pygeoapi-config.yml

# Luego generar de nuevo
pygeoapi openapi generate config/pygeoapi-config.yml > config/openapi.yml
```

## Verificación Final

Ejecuta estos comandos para verificar:

```bash
# 1. Verificar directorios
[ -d "config" ] && echo "✓ Directorio config existe"
[ -d "logs" ] && echo "✓ Directorio logs existe"

# 2. Verificar archivo de configuración
[ -f "config/pygeoapi-config.yml" ] && echo "✓ Archivo de configuración existe"

# 3. Validar configuración
pygeoapi config validate config/pygeoapi-config.yml

# 4. Verificar OpenAPI
[ -f "config/openapi.yml" ] && echo "✓ OpenAPI generado"
```

## Configuraciones Avanzadas (Opcional)

### Habilitar HTTPS

```yaml
server:
    bind:
        host: 0.0.0.0
        port: 443
    url: https://tudominio.com
```

### Configurar Múltiples Idiomas

```yaml
server:
    languages:
        - es
        - en
        - pt
        - fr
```

### Ajustar Límites de Paginación

```yaml
server:
    limit: 10        # Límite por defecto
    max_limit: 10000 # Límite máximo permitido
```

## Siguiente Paso

Una vez completada la configuración básica, continúa con:
- **Paso 4:** Configuración del provider GeoPackage (rama `feature_step_4`)

## Checklist de Verificación

- [ ] Directorio `config/` creado
- [ ] Directorio `logs/` creado
- [ ] Archivo `config/pygeoapi-config.yml` creado
- [ ] Configuración personalizada (metadata, contact)
- [ ] Configuración validada exitosamente
- [ ] OpenAPI generado en `config/openapi.yml`

---

**Referencia:** Ver [SETUP_GUIDE.md](SETUP_GUIDE.md) para la guía completa.
