# Dockerfile del repositorio base.
# Contiene cinco malas practicas deliberadas. Cada una lleva su numero en la
# linea anterior. Corregirlas es el bloque A1 de la guia del laboratorio.

# Corrección Defecto 1: Versión fija e inmutable
FROM public.ecr.aws/lambda/nodejs:20 AS builder

WORKDIR /var/task

# Corrección Defecto 2 y 3: Copiar manifiestos primero e instalar con npm ci
COPY package*.json ./
RUN npm ci

# Copiar el resto del código y construir el artefacto con esbuild (genera dist/handler.js)
COPY src/ ./src/
RUN npm run build

# Corrección Defecto 4 y 5: Sin credenciales, sin herramientas de depuración (vim, procps-ng) y sin node_modules
FROM public.ecr.aws/lambda/nodejs:20

WORKDIR /var/task

# Copiar únicamente el archivo empaquetado desde la etapa builder
COPY --from=builder /var/task/dist/handler.js ./

CMD [ "handler.handler" ]
