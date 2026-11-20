# Práctica 10 - API de imágenes con FastAPI y Flutter

Aplicaciones Móviles · UTEQ · Gustavo Aarón Vargas Joachín · LITIID019

API en FastAPI que sube, guarda y lista imágenes en MySQL, y una app en Flutter que toma fotos, las sube y las muestra en una galería.

## Estructura

- `api/` API en FastAPI (`main.py`) y script de la base de datos (`practica10.sql`)
- La raíz del repositorio es la app en Flutter (`lib/`, `android/`, `pubspec.yaml`)

## Base de datos

Ejecutar `api/practica10.sql` en phpMyAdmin. Crea la base `practica10` con la tabla `P10_foto` (id, descripcion, ruta_foto, fecha).

## API

```
cd api
pip install -r requirements.txt
uvicorn main:app --host 0.0.0.0 --port 8000
```

| Método | Ruta | Qué hace |
|---|---|---|
| POST | `/fotos` | Sube una foto con `descripcion` y `file` en form-data. Solo acepta jpeg, png, webp y gif |
| GET | `/fotos` | Lista las fotos de la más nueva a la más vieja |
| GET | `/uploads/{archivo}` | Sirve la imagen como archivo estático |

Documentación: http://localhost:8000/docs

## App Flutter

```
flutter pub get
flutter run
```

En el emulador la app usa `http://10.0.2.2:8000`. En un teléfono físico hay que cambiar `baseUrl` en `lib/main.dart` por la IP de la computadora.

- **Subir foto:** tomar foto con la cámara o elegirla de la galería, escribir la descripción y subirla.
- **Galería (reto):** muestra todas las fotos que hay en la API con su descripción y fecha; al tocar una se ve en grande.
