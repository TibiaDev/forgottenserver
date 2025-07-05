# Stage 1: Build
FROM ubuntu:24.04 AS build

ENV DEBIAN_FRONTEND=noninteractive
ENV BUILD_SERVER_ONLY=1
ENV VCPKG_ROOT=/opt/vcpkg
ENV VCPKG_DEFAULT_TRIPLET=x64-linux-release
ENV VCPKG_DEFAULT_BINARY_CACHE=/opt/vcpkg/vcpkg-binary
ENV VCPKG_INSTALLED_DIR=/opt/vcpkg/vcpkg_installed

# Instala ferramentas essenciais
RUN --mount=type=cache,target=/var/cache/apt \
    apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    clang \
    cmake \
    curl \
    git \
    unzip \
    zip \
    pkg-config \
    ca-certificates \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Instala o vcpkg
WORKDIR /opt
RUN git clone https://github.com/microsoft/vcpkg.git && \
    ./vcpkg/bootstrap-vcpkg.sh

ENV PATH="${VCPKG_ROOT}:${PATH}"
ENV CMAKE_TOOLCHAIN_FILE=${VCPKG_ROOT}/scripts/buildsystems/vcpkg.cmake

# Copia arquivos do projeto
WORKDIR /usr/src/forgottenserver
COPY vcpkg.json CMakeLists.txt ./
COPY cmake ./cmake
COPY src ./src

# Cria diretórios de cache
RUN mkdir -p ${VCPKG_DEFAULT_BINARY_CACHE} ${VCPKG_INSTALLED_DIR}

# Instala as dependências do vcpkg com cache de binário e installed
RUN --mount=type=cache,target=${VCPKG_INSTALLED_DIR} \
    --mount=type=cache,target=${VCPKG_DEFAULT_BINARY_CACHE} \
    ${VCPKG_ROOT}/vcpkg install

# Build com cache
WORKDIR /usr/src/forgottenserver/build
RUN rm -rf ./* || true

RUN --mount=type=cache,target=${VCPKG_INSTALLED_DIR} \
    cmake .. \
      -DCMAKE_TOOLCHAIN_FILE=${CMAKE_TOOLCHAIN_FILE} \
      -DVCPKG_TARGET_TRIPLET=${VCPKG_DEFAULT_TRIPLET} \
      -DVCPKG_INSTALLED_DIR=${VCPKG_INSTALLED_DIR} \
      -DCMAKE_BUILD_TYPE=Release \
      -DVCPKG_BUILD_TYPE=release \
 && cmake --build . -- -j$(nproc)

# Stage 2: Runtime (mínimo)
FROM ubuntu:24.04 AS runtime

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    libssl3 libmariadb3 libluajit-5.1-2 libfmt-dev libcrypto++8 \
    libboost-iostreams1.74.0 libboost-system1.74.0 libboost-filesystem1.74.0 \
    libboost-locale1.74.0 libpugixml1v5 ca-certificates \
 && rm -rf /var/lib/apt/lists/*

COPY --from=build /usr/src/forgottenserver/build/tfs /bin/tfs

COPY data /srv/data/
COPY LICENSE README.md *.dist *.sql key.pem config.lua /srv/

EXPOSE 7171 7172
WORKDIR /srv
VOLUME /srv
ENTRYPOINT ["/bin/tfs"]
