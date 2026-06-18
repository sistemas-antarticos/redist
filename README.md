# Redistribución del Sistema Antártico (redist)

Este repositorio almacena los recursos y configuraciones de infraestructura necesarios para desplegar y administrar el **Sistema de Streaming Antártico**.

## Estructura Global del Proyecto

Es importante mencionar que este proyecto está compuesto por múltiples repositorios. Mientras que este repositorio (`redist`) es público y contiene la infraestructura de despliegue, el código fuente de las aplicaciones principales se encuentra en repositorios **privados** por motivos de seguridad y organización:

*   **Manager**: Contiene el código fuente (backend y frontend) del Panel de Control, desarrollado en Laravel, responsable de la gestión de contenidos, orquestación y administración.
*   **Player**: Contiene el código fuente del Cliente de Visualización, responsable de la reproducción autónoma y sincronización en las pantallas del museo.
*   **Documentos**: Almacena toda la documentación técnica, manuales, y especificaciones (SRS, LDD) redactados en LaTeX.

## Contenido de este repositorio

Principalmente incluye configuraciones clave para la orquestación y el despliegue de los servicios:
- **core**: Archivos base y de configuración (`docker-compose.yml`, entornos de ejemplo) para levantar los servicios principales del sistema.
- **portainer**: Configuración para desplegar Portainer, lo que facilita la gestión visual y administración de los contenedores de Docker utilizados a lo largo del proyecto.
