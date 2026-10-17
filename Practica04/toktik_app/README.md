# TokTik

La app obtiene los videos de «Para ti» y «Favoritos» desde una carpeta de Google Drive mediante Drive API v3.

## Configuración de Google Drive

1. Crea o selecciona un proyecto en Google Cloud y habilita **Google Drive API**.
2. Crea una API key.
3. Comparte la carpeta y sus videos con acceso **Cualquier persona con el enlace: Lector**.
4. Copia el ID de la carpeta desde su URL: `https://drive.google.com/drive/folders/ID_DE_CARPETA`.
5. Edita `lib/config/google_drive_config.dart` y configura `folderId` y `apiKey`.
6. Ejecuta `flutter run` normalmente.

Se listan los archivos cuyo tipo MIME comienza con `video/`, ordenados por nombre.

## Feed Descubrir

El feed **Descubrir** mezcla videos de YouTube Data API v3, PeerTube y Dailymotion. Los feeds **Para ti** y **Favoritos** continúan usando los videos de Google Drive.

### Configurar la API key

1. Abre [Google Cloud Console](https://console.cloud.google.com/) e inicia sesión.
2. Selecciona un proyecto existente o crea uno.
3. En **APIs y servicios > Biblioteca**, busca **YouTube Data API v3** y pulsa **Habilitar**.
4. Ve a **APIs y servicios > Credenciales > Crear credenciales > Clave de API**.
5. Abre la clave creada y, en **Restricciones de API**, selecciona **Restringir clave** y deja habilitada solo **YouTube Data API v3**. Guarda los cambios.
6. Copia la clave en `lib/config/youtube_config.dart`, reemplazando `PEGA_AQUI_TU_API_KEY_DE_YOUTUBE`.
7. Ejecuta la app normalmente con `flutter run`.

La clave queda incluida en la app compilada y puede extraerse. Restringirla a YouTube Data API v3 limita su uso a ese servicio. Para publicar la app, considera servir estas llamadas desde un backend y no subir una clave real a un repositorio público.

La búsqueda de YouTube solicita videos relacionados con `shorts`; YouTube no ofrece un filtro de API que garantice que un resultado sea un Short. Dailymotion usa la búsqueda pública de Platform API y su reproductor embebido oficial.

### Dailymotion

La búsqueda de videos públicos no necesita API key ni inicio de sesión. La app usa un Player ID compartido de ejemplo que Dailymotion publica en su documentación; si tienes un Player ID propio, puedes reemplazarlo en `lib/config/dailymotion_config.dart`. El Player ID es necesario porque Dailymotion rechaza los embeds sin uno.
