# SONORA — biblioteca musical offline-first

Aplicación web estática (HTML/CSS/JavaScript ES modules) inspirada en la organización del proyecto Biblioteca compartido. Backend: Supabase (Postgres, Auth, RLS y Edge Functions). PWA: Service Worker + IndexedDB.

## Requisitos
- Proyecto Supabase.
- Cuenta de desarrollador Jamendo y `client_id` para catálogo musical.
- Freesound API key si se habilitan sonidos ambientales.
- Servir por HTTPS o localhost (no abrir `index.html` con `file://`).

## Configuración inicial
1. Crea un proyecto en Supabase.
2. En SQL Editor ejecuta `supabase/schema.sql`.
3. Copia Project URL y Publishable key desde Supabase a `config/supabase.js`.
4. Instala Supabase CLI. En la carpeta del proyecto ejecuta `supabase init`, luego `supabase login` y `supabase link --project-ref TU_PROJECT_REF`.
5. Configura secretos: `supabase secrets set JAMENDO_CLIENT_ID=TU_CLIENT_ID FREESOUND_API_KEY=TU_API_KEY SUPABASE_URL=https://TU-PROYECTO.supabase.co SUPABASE_SERVICE_ROLE_KEY=TU_SERVICE_ROLE_KEY`. La service role key se usa exclusivamente dentro de la función, nunca en el navegador ni en Git.
6. Despliega funciones: `supabase functions deploy music-search` y `supabase functions deploy sound-search`.
7. Sirve la carpeta desde un servidor local, por ejemplo `python -m http.server 5500`, y abre `http://localhost:5500`.

## Importante sobre las licencias
- La API de Jamendo permite consultar un catálogo amplio. El campo `audiodownload_allowed` determina si la aplicación puede ofrecer descarga de esa pista; no mostrar descarga si es `false`.
- Revisa los términos de Jamendo y la licencia concreta de cada pista antes de publicar o monetizar el servicio.
- Freesound está pensado para sonidos/efectos, no como sustituto de un catálogo de canciones completas. Cada sonido tiene licencia propia; respeta atribución y condiciones. Su API gratuita está limitada a usos no comerciales salvo acuerdo específico.
- Internet Archive se deja como integración planificada: no todo lo que aloja es de dominio público. Antes de incorporarlo, validar rights/license a nivel de cada item y archivo.
- Spotify no se usa para extraer audio ni descargar canciones protegidas.

## Offline-first
- La interfaz y archivos de aplicación se guardan en Cache Storage.
- Favoritos, listas y metadatos se guardan localmente en IndexedDB.
- La descarga de audio requiere que la fuente permita la descarga y que el navegador pueda acceder al archivo (CORS). En esta primera versión, la descarga local se realiza desde la pista reproducible; algunas fuentes pueden bloquearla.
- La sincronización de favoritos/listas con Supabase se amplía en la siguiente iteración; la base de datos ya incluye las tablas y políticas.

## Seguridad
Nunca pongas `service_role`, claves privadas o tokens de APIs en `config/supabase.js` ni en el frontend. Los secretos de proveedores van en Supabase Edge Functions.
