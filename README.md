forgottenserver (v1.4.3) [![Build Status](https://github.com/otland/forgottenserver/actions/workflows/build-vcpkg.yml/badge.svg?branch=master)](https://github.com/otland/forgottenserver/actions/workflows/build-vcpkg.yml "vcpkg build status") [![Build Status](https://github.com/otland/forgottenserver/actions/workflows/docker-image.yml/badge.svg?branch=master)](https://github.com/otland/forgottenserver/actions/workflows/docker-image.yml "Docker image build status")
===============

The Forgotten Server is a free and open-source MMORPG server emulator written in C++. It is a fork of the [The Forgotten Server (using tag: v1.4.2)](https://github.com/otland/forgottenserver/) project.

To connect to the server, you can use [OTClient](https://github.com/edubart/otclient) or [OTCV8](https://github.com/OTCv8/otclientv8) or [OTCR](https://github.com/mehah/otclient).

In this fork contains the minimal updates on c++ and libraries to runs this version using the latest Visual Studio with vcpkg manifest, the latest ubuntu versions 22/24 or using docker compose (windows and linux/ubuntu).

### Build with Visual Studio 2022 and Vcpkg
Do you need install the lasted visual studio 2022 with c++, and install and setup your vcpkg.

Open the solution and build, all packages are downloaded automatically by vcpkg.json file (vcpkg manifest)

### Build with Ubuntu 22/24
Execute the following steps:
- Install build dependencies: `sudo apt install -y build-essential clang cmake make gcc g++ pkg-config`
- Install libraries: `sudo apt install -y libboost-all-dev libcrypto++-dev libfmt-dev libgmp-dev libluajit-5.1-dev libmariadb-dev ibpugixml-dev`
- Build source files: `mkdir build && cd build && cmake .. && make -j$(grep processor /proc/cpuinfo | wc -l)`
- Move server file: `cd build && mv theforgottenserver ..`
- Run server file: `cd ../ && ./theforgottenserver`

### Build docker
Do you need install the lasted docker desktop version on windows, or the last versions of docker and docker compose on linux/unbuntu.

And execute the command: `docker compose up --build`

![image](https://github.com/user-attachments/assets/3e86425d-c416-4fc1-b0ac-291b59aceacc)
