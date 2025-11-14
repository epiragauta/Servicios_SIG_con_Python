# Servicios SIG con Python - pygeoapi

Proyecto de configuración paso a paso de **pygeoapi** para publicar datos geoespaciales del Amazonas como servicios OGC API.

## Descripción

Este proyecto proporciona una guía completa y estructurada para configurar y desplegar pygeoapi, una implementación en Python de los estándares OGC API. El proyecto utiliza datos geoespaciales del Amazonas almacenados en formato GeoPackage.

## Características

- ✅ Configuración paso a paso de pygeoapi
- ✅ Soporte para GeoPackage como fuente de datos
- ✅ API REST conforme a estándares OGC API - Features
- ✅ Documentación interactiva OpenAPI
- ✅ Soporte multiidioma (español e inglés)
- ✅ Scripts de automatización para instalación y configuración
- ✅ Scripts de pruebas automatizadas
- ✅ Configuración Docker incluida
- ✅ Modo desarrollo y producción

## Estructura del Proyecto

```
Servicios_SIG_con_Python/
├── datos/
│   └── amazonas.gpkg          # Datos geoespaciales
├── config/
│   └── pygeoapi-config.yml    # Configuración principal
├── logs/                       # Archivos de log
├── SETUP_GUIDE.md             # Guía completa de configuración
├── paso1_dependencias.md      # Paso 1: Instalación de dependencias
├── paso2_instalacion.md       # Paso 2: Instalación de pygeoapi
├── paso3_configuracion.md     # Paso 3: Configuración básica
├── paso4_provider.md          # Paso 4: Configuración del provider
├── paso5_ejecucion.md         # Paso 5: Ejecución del servicio
├── paso6_pruebas.md           # Paso 6: Pruebas y verificación
├── install_dependencies.sh    # Script instalación de dependencias
├── install_pygeoapi.sh        # Script instalación de pygeoapi
├── setup_config.sh            # Script configuración básica
├── config_provider.sh         # Script configuración provider
├── inspect_gpkg.py            # Script inspección GeoPackage
├── test_gpkg.py               # Script prueba GeoPackage
├── start.sh                   # Script inicio (desarrollo)
├── start_production.sh        # Script inicio (producción)
├── stop.sh                    # Script detención
├── test_api.sh                # Script pruebas (bash)
├── test_api.py                # Script pruebas (python)
├── load_test.sh               # Script pruebas de carga
├── Dockerfile                 # Configuración Docker
└── docker-compose.yml         # Orquestación Docker
```

## Ramas del Proyecto

El proyecto está organizado en ramas que representan cada paso del proceso de configuración:

- **`feature_step_1`**: Instalación de dependencias del sistema
- **`feature_step_2`**: Instalación de pygeoapi
- **`feature_step_3`**: Configuración básica
- **`feature_step_4`**: Configuración del provider GeoPackage
- **`feature_step_5`**: Ejecución del servicio
- **`feature_step_6`**: Pruebas y verificación

Cada rama incluye toda la documentación y scripts necesarios para ese paso específico.

## Inicio Rápido

### Opción 1: Instalación Completa Paso a Paso

Sigue la [Guía de Configuración Completa](SETUP_GUIDE.md) que incluye todos los pasos detallados.

### Opción 2: Instalación Rápida

```bash
# 1. Instalar dependencias del sistema
./install_dependencies.sh

# 2. Activar entorno virtual
source venv/bin/activate

# 3. Instalar pygeoapi
./install_pygeoapi.sh

# 4. Configurar el servicio
./setup_config.sh

# 5. Configurar el provider
./config_provider.sh

# 6. Iniciar el servidor
./start.sh
```

### Opción 3: Docker

```bash
# Construir y ejecutar con Docker Compose
docker-compose up -d

# Ver logs
docker-compose logs -f

# Detener
docker-compose down
```

## Verificación

Una vez iniciado el servidor, verifica que funciona:

```bash
# Ejecutar pruebas bash
./test_api.sh

# O ejecutar pruebas Python
./test_api.py
```

## Endpoints Principales

Una vez que el servidor esté ejecutándose en http://localhost:5000:

- **Landing Page**: http://localhost:5000
- **Documentación OpenAPI**: http://localhost:5000/openapi?f=html
- **Colecciones**: http://localhost:5000/collections
- **Colección Amazonas**: http://localhost:5000/collections/amazonas
- **Items (Features)**: http://localhost:5000/collections/amazonas/items

## Requisitos

### Sistema Operativo
- Linux (Ubuntu/Debian, CentOS/RHEL)
- macOS
- Windows (con WSL)

### Software
- Python 3.8 o superior
- GDAL 3.0 o superior
- pip
- virtualenv

## Documentación

- **[SETUP_GUIDE.md](SETUP_GUIDE.md)**: Guía completa de configuración
- **[paso1_dependencias.md](paso1_dependencias.md)**: Instalación de dependencias
- **[paso2_instalacion.md](paso2_instalacion.md)**: Instalación de pygeoapi
- **[paso3_configuracion.md](paso3_configuracion.md)**: Configuración básica
- **[paso4_provider.md](paso4_provider.md)**: Configuración del provider
- **[paso5_ejecucion.md](paso5_ejecucion.md)**: Ejecución del servicio
- **[paso6_pruebas.md](paso6_pruebas.md)**: Pruebas y verificación

## Desarrollo

### Estructura de Ramas

Para explorar cada paso individualmente, cambia a la rama correspondiente:

```bash
# Paso 1: Instalación de dependencias
git checkout feature_step_1

# Paso 2: Instalación de pygeoapi
git checkout feature_step_2

# Paso 3: Configuración básica
git checkout feature_step_3

# Paso 4: Configuración del provider
git checkout feature_step_4

# Paso 5: Ejecución del servicio
git checkout feature_step_5

# Paso 6: Pruebas y verificación
git checkout feature_step_6
```

### Modo Desarrollo

```bash
# Iniciar en modo desarrollo (con logs en consola)
./start.sh
```

### Modo Producción

```bash
# Iniciar en modo producción (daemon con Gunicorn)
./start_production.sh

# Ver logs
tail -f logs/access.log
tail -f logs/error.log

# Detener
./stop.sh
```

## Pruebas

### Pruebas Funcionales

```bash
# Pruebas con bash
./test_api.sh

# Pruebas con Python (más detalladas)
./test_api.py
```

### Pruebas de Carga

```bash
# Ejecutar 100 peticiones (por defecto)
./load_test.sh

# Ejecutar N peticiones
./load_test.sh 500
```

## Personalización

### Modificar Configuración

Edita el archivo `config/pygeoapi-config.yml` para:
- Cambiar puerto del servidor
- Agregar más colecciones
- Modificar metadatos
- Configurar otros providers

### Agregar Más Datos

1. Coloca tus archivos GeoPackage en `datos/`
2. Edita `config/pygeoapi-config.yml`
3. Agrega una nueva sección en `resources`
4. Regenera OpenAPI: `pygeoapi openapi generate config/pygeoapi-config.yml > config/openapi.yml`
5. Reinicia el servidor

## Solución de Problemas

### El servidor no inicia

```bash
# Verificar configuración
pygeoapi config validate config/pygeoapi-config.yml

# Ver logs
tail -f logs/pygeoapi.log
```

### Puerto 5000 en uso

```bash
# Cambiar el puerto en config/pygeoapi-config.yml
# O matar el proceso que usa el puerto
lsof -ti:5000 | xargs kill -9
```

### Error al acceder a datos

```bash
# Verificar acceso al GeoPackage
./test_gpkg.py

# Inspeccionar GeoPackage
./inspect_gpkg.py
```

## Recursos Adicionales

- [Documentación oficial de pygeoapi](https://docs.pygeoapi.io)
- [OGC API - Features](https://ogcapi.ogc.org/features/)
- [GeoPackage Specification](https://www.geopackage.org/)
- [GDAL Documentation](https://gdal.org/)

## Licencia

Este proyecto está bajo la licencia CC-BY 4.0.

## Contribuciones

Las contribuciones son bienvenidas. Por favor:
1. Fork el proyecto
2. Crea una rama para tu feature
3. Commit tus cambios
4. Push a la rama
5. Abre un Pull Request

## Autor

Proyecto creado como guía educativa para la configuración de pygeoapi.

## Soporte

Si encuentras algún problema o tienes preguntas:
1. Revisa la [documentación](SETUP_GUIDE.md)
2. Verifica los [scripts de prueba](paso6_pruebas.md)
3. Consulta los logs del sistema

---

**Última actualización**: 2025-11-07
