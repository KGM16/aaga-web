# Utiliza la imagen base de Node.js LTS para construir la aplicación
FROM node:lts-alpine AS builder

# Establece el directorio de trabajo dentro del contenedor
WORKDIR /app

# Copia los archivos package*.json y package-lock.json (o yarn.lock)
COPY package*.json ./

# Instala las dependencias del proyecto
RUN npm install --frozen-lockfile

# Copia la carpeta node_modules explícitamente (intento de solución anterior)
COPY node_modules ./node_modules

# Copia el resto de los archivos y carpetas del proyecto
COPY . .

# Construye la aplicación Astro para producción
RUN npm run build

# --- Fase para servir los archivos estáticos con un servidor web ligero ---
FROM nginx:alpine

# Elimina la configuración por defecto de Nginx
RUN rm /etc/nginx/conf.d/default.conf

# Copia la configuración de Nginx personalizada desde la subcarpeta 'nginx'
COPY nginx/nginx.conf /etc/nginx/conf.d/default.conf

# Copia los archivos construidos desde la fase de "builder"
COPY --from=builder /app/dist /usr/share/nginx/html

# Expone el puerto 80 para acceder a la aplicación
EXPOSE 80

# Comando para iniciar el servidor Nginx
CMD ["nginx", "-g", "daemon off;"]