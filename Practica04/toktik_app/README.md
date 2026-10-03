# TokTik

La app obtiene los videos desde una carpeta de Google Drive mediante Drive API v3.

## Configuración de Google Drive

1. Crea o selecciona un proyecto en Google Cloud y habilita **Google Drive API**.
2. Crea una API key.
3. Comparte la carpeta y sus videos con acceso **Cualquier persona con el enlace: Lector**.
4. Copia el ID de la carpeta desde su URL: `https://drive.google.com/drive/folders/ID_DE_CARPETA`.
5. Edita `lib/config/google_drive_config.dart` y reemplaza `folderId` y `apiKey`.
6. Ejecuta `flutter run` normalmente; no necesitas pasar argumentos adicionales.

Se listan los archivos cuyo tipo MIME comienza con `video/`, ordenados por nombre.
La API key está escrita directamente en el código para esta práctica.
