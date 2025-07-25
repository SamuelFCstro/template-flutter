# Etapa 1: Construção do aplicativo Flutter
FROM debian:latest AS build-env

# Instalar pacotes necessários
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    ninja-build \
    pkg-config \
    libstdc++6 \
    ca-certificates

# Definir variáveis de ambiente
ARG FLUTTER_SDK=/usr/local/flutter
ARG APP=/app/
ARG FLUTTER_VERSION=3.27.3

# Clonar o SDK do Flutter e configurar o canal stable
RUN git clone https://github.com/flutter/flutter.git $FLUTTER_SDK

# Alterar para o diretório do Flutter e fazer o checkout para uma versão específica (se necessário)
RUN cd $FLUTTER_SDK && git fetch && git checkout $FLUTTER_VERSION

# Configurar o Flutter no PATH
ENV PATH="$FLUTTER_SDK/bin:$FLUTTER_SDK/bin/cache/dart-sdk/bin:$PATH"

# Verificar a instalação do Flutter
RUN flutter doctor -v

# Criar o diretório para o código-fonte
RUN mkdir -p $APP
WORKDIR $APP

# Copiar o código-fonte para dentro do container
COPY . .

# Instalar dependências do Flutter e fazer o build do aplicativo
RUN flutter build web --base-href "/{{alterar-nome-projeto}}/" || echo "Erro ao construir o projeto"

# Etapa 2: Servir o aplicativo com o NGINX

# FROM nginx:1.25.2-alpine
FROM nginx:latest

# Criar o diretório no NGINX antes de copiar os arquivos
RUN mkdir -p /usr/share/nginx/html/{{alterar-nome-projeto}}

# Copiar os arquivos construídos para o NGINX
COPY --from=build-env /app/build/web /usr/share/nginx/html/{{alterar-nome-projeto}}

# Copiar a configuração personalizada do NGINX
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expor a porta 80 para o tráfego HTTP
EXPOSE 80

# Iniciar o servidor NGINX
CMD ["nginx", "-g", "daemon off;"]
