# Desarrollo local y primer contrato: texto

Requisitos: Docker Desktop iniciado y los repositorios manager, player y redist como carpetas hermanas. No hace falta instalar PHP, Composer ni Node en Windows. Este entorno compila el código de tus carpetas; no usa las imágenes publicadas del sistema ni requiere commits, tags o GitHub Actions.

## Iniciar

Desde la carpeta redist:

```powershell
docker compose -f dev/docker-compose.yml up -d --build
docker compose -f dev/docker-compose.yml logs -f manager manager-vite player
```

La primera vez descarga imágenes e instala dependencias; esperá a que Manager anuncie el puerto 8000 y los dos servidores Vite estén listos. Ctrl+C deja de mostrar los logs y mantiene los contenedores encendidos.

- Manager: http://localhost:8000. La primera vez creá tu administrador en la pantalla de configuración inicial.
- Player: http://localhost:5174. Mostrará un código de vinculación; aprobalo desde Registros en el Manager.
- Creá un diseño, agregá Texto, guardalo y asignalo al monitor vinculado. Abrí ambas pestañas para comparar.

El puerto 5173 sirve los recursos del Manager: no es la página del panel. La base y los archivos subidos se guardan en volúmenes propios del proyecto antartico-dev. No se modifica tu .env ni se levantan DNS o Traefik. Los servicios web sólo se exponen en esta PC.

Para detenerlo conservando datos:

```powershell
docker compose -f dev/docker-compose.yml down
```

La próxima vez, `up -d` alcanza. Usá `up -d --build` si modificás manager.Dockerfile. No uses `down -v` salvo que quieras borrar los datos locales.

## Qué se implementó

Las fuentes editables están en `manager/contracts`: `widgets/texto.widget.json` define los campos; `widgets/texto.richtext.json` define el HTML permitido, la paleta y las herramientas; `runtime/text-richtext.mjs` y `.css` comparten limpieza y presentación entre navegadores. Los otros widgets mantienen su implementación.

- Los dos editores del Manager usan defaults al crear texto y generan sus controles recorriendo editor.
- Un solo módulo, resources/js/widgets/text-widget.js, renderiza el texto en ambos editores y en ambas vistas previas del Manager.
- El servicio TextWidgetContract normaliza datos y los valida con Opis antes de guardar. Un error devuelve 422 y conserva el diseño anterior.
- El Player usa una copia versionada, tipos TypeScript y un validador JavaScript generado con Ajv. Los datos se validan antes de reemplazar el caché; una versión no soportada conserva el caché válido anterior. Sin un caché válido, no puede reproducir esa configuración.
- Texto usa un solo contrato y un solo formato HTML limitado. No se mantienen implementaciones antiguas ni un modo Markdown. No se ejecuta una migración de tus diseños guardados.

## Probar un cambio pequeño

1. Abrí manager/contracts/widgets/texto.widget.json en VS Code. Cambiá el label del campo color por «Color del título» y recargá el Manager: los dos editores mostrarán esa etiqueta.
2. Cambiá defaults.color a #ffcc00. Al agregar **un nuevo widget de texto**, empezará amarillo. Los widgets que ya tienen color guardado lo conservan.
3. Sincronizá la copia del Player:

```powershell
docker compose -f dev/docker-compose.yml exec player pnpm contracts:sync --source /contracts-source/widgets
```

4. En el formulario, modificá el texto, el color y «Margen interior» (por ejemplo 32px). Guardá el diseño. La vista previa y el Player deben mostrar el cambio; el Player recibe las actualizaciones mediante SSE. También podés recargar su pestaña para pedir la última configuración.

El Manager recarga PHP por petición y sus recursos con Vite. Svelte usa recarga de cambios. Tras editar un contrato, recargá la pestaña del Manager y ejecutá la sincronización anterior: en esta primera versión la sincronización no observa cambios automáticamente. El arranque del contenedor Player también sincroniza una vez.

Cambiar labels o defaults no agrega un comportamiento visual. Para agregar un campo nuevo hay que declararlo en schema.properties, defaults y editor dentro del mismo archivo; luego sincronizar e implementar su efecto en text-widget.js y Text.svelte. Los controles genéricos ya se generan, pero los renderers deben saber qué hacer con el dato.

El editor visual usa Tiptap sólo en Manager. PHP limpia con Symfony HTML Sanitizer y los navegadores con DOMPurify. El perfil compartido tiene ayuda y autocompletado de VS Code. Más detalles en `manager/contracts/widgets/README.md`.

Después de incorporar estas dependencias por primera vez, desde redist:

```powershell
docker compose -f dev/docker-compose.yml exec manager composer install --no-interaction
docker compose -f dev/docker-compose.yml up -d --force-recreate manager-vite player
```

Esto conserva la base y los diseños locales. Esperá a que ambos servidores Vite estén listos y recargá el navegador. No requiere publicar nada en Git.

## Compilación independiente y verificaciones

Con Node/pnpm instalados, también podés ejecutar `pnpm contracts:sync` desde player: busca el contrato en la carpeta hermana manager. En Docker se usa --source porque el contrato está montado en otra ruta.

La copia contracts/widgets, contracts.lock.json y src/generated se guardan junto al código del Player. Su build verifica que coincidan y compila únicamente archivos del propio repositorio. El Dockerfile de producción sigue entregando dist a Nginx; el navegador no descarga schemas para reproducir.

Para construir también esa imagen sin publicar nada, ejecutá `docker build -t antartico-player-text-contract:local .` desde player. El build usa Node 24 y pnpm 11.0.8; la etapa final sigue siendo Nginx.

```powershell
docker compose -f dev/docker-compose.yml exec player pnpm contracts:check --source /contracts-source/widgets
docker compose -f dev/docker-compose.yml exec player pnpm test src/tests/unit/textContract.test.ts src/tests/unit/appState.test.ts src/tests/components/Text.test.ts
docker compose -f dev/docker-compose.yml exec player pnpm build
docker compose -f dev/docker-compose.yml exec manager-vite npm run build
```

Las pruebas PHP necesitan PostgreSQL porque las migraciones del sistema crean triggers propios de ese motor. Creá una base exclusiva una vez:

```powershell
docker compose -f dev/docker-compose.yml exec db createdb -U antartico_dev antartico_test
docker compose -f dev/docker-compose.yml exec -e APP_ENV=testing -e DB_DATABASE=antartico_test manager php artisan test --compact tests/Feature/TextWidgetContractTest.php
```

Si la base antartico_test ya existe, omití createdb. Nunca ejecutes estas pruebas sobre antartico_dev: RefreshDatabase reconstruye las tablas de la base indicada.

Los fixtures del contrato se validan con los dos motores, PHP y JavaScript. contracts:check también verifica defaults, versiones, referencias de los controles y archivos generados. Para comprobar si la copia está actualizada contra Manager se usa --source; un build aislado sólo puede comprobar su propia copia.

La PWA está desactivada en desarrollo para facilitar la recarga. Si ya usaste una PWA en este mismo origen y ves archivos viejos, eliminá su service worker en las herramientas del navegador. Las pruebas de caché offline de producción deben hacerse con el build final.
