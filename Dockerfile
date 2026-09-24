# Dockerfile del repositorio base.
# Contiene cinco malas practicas deliberadas. Cada una lleva su numero en la
# linea anterior. Corregirlas es el bloque A1 de la guia del laboratorio.

# Dockerfile corregido para el bloque A1

# Corrección Defecto 1: Versión fija e inmutable (etapa 'build')
FROM public.ecr.aws/lambda/nodejs:20 AS build

# Corrección Defecto 2: Establecer WORKDIR /build y copiar manifiestos primero
WORKDIR /build
COPY package*.json ./

# Corrección Defecto 3: Instalación determinista desde el lock file
RUN npm ci

# Corrección Defecto 4 y 5: Copiar código fuente sin credenciales ni instalaciones de dnf
COPY src/ ./src/

### NO TOCAR DE ACA EN ADELANTE, CONSIDEREN QUE EL WORKDIR DEBE SER /build
RUN npx esbuild src/handler.js \
      --bundle --platform=node --target=node20 \
      --outfile=dist/handler.js

# Etapa final: recibe unicamente el artefacto empaquetado.
# El arbol de node_modules se queda en la etapa anterior.
FROM public.ecr.aws/lambda/nodejs:20 AS runtime
COPY --from=build /build/dist/handler.js ${LAMBDA_TASK_ROOT}/
CMD ["handler.handler"]
