# Stage 1: Build
FROM alpine:3.19 AS build
# install libs
RUN apk add --no-cache \
  binutils \
  boost-dev \
  build-base \
  clang \
  cmake \
  crypto++-dev \
  fmt-dev \
  gcc \
  gmp-dev \
  luajit-dev \
  make \
  mariadb-connector-c-dev \
  pugixml-dev

# Copy source files
COPY cmake /usr/src/forgottenserver/cmake/
COPY src /usr/src/forgottenserver/src/
COPY CMakeLists.txt /usr/src/forgottenserver/

# Build the project
WORKDIR /usr/src/forgottenserver/build
RUN cmake .. && make

# Stage 2: Runtime
FROM alpine:3.19.0 AS runtime
# install libs
RUN apk add --no-cache \
  boost-iostreams \
  boost-system \
  boost-filesystem \
  crypto++ \
  fmt \
  gmp \
  luajit \
  mariadb-connector-c \
  pugixml

# Copy the built binary from the build stage
COPY --from=build /usr/src/forgottenserver/build/tfs /bin/tfs

# Copy configuration and data files
COPY data /srv/data/
COPY LICENSE README.md *.dist *.sql key.pem config.lua /srv/

# Expose the necessary ports
EXPOSE 7171 7172

# Set working directory and volumes
WORKDIR /srv
VOLUME /srv

# Define the entrypoint
ENTRYPOINT ["/bin/tfs"]
