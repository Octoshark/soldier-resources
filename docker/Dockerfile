# Rudimentary Dockerfile (First time :D)
FROM registry.gitlab.steamos.cloud/steamrt/soldier/sdk

ARG USER_ID
ARG GROUP_ID

# Create working directory to do some work in
RUN mkdir /working

# Clone and build GCC-12.1.0
RUN cd /working && git clone git://gcc.gnu.org/git/gcc.git --recurse -b releases/gcc-12.1.0
RUN cd /working && wget https://raw.githubusercontent.com/Octoshark/soldier-resources/main/gcc/gcc-patch.diff && wget https://raw.githubusercontent.com/Octoshark/soldier-resources/main/gcc/build_gcc_soldier.sh && chmod +x build_gcc_soldier.sh
RUN cd /working && ./build_gcc_soldier.sh
RUN cd /working && tar xf gcc12.tar.gz -C /

# Soldier has no update-alternatives specified for gcc/g++, so this automatically bumps us to gcc-12/g++-12
RUN update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-12 12
RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-12 12

# Download, build, and install CMake 3.24.1
RUN cd /working && wget https://github.com/Kitware/CMake/releases/download/v3.24.1/cmake-3.24.1.tar.gz
RUN cd /working && tar xf cmake-3.24.1.tar.gz
RUN cd /working/cmake-3.24.1 && mkdir build && cd build && cmake .. -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr && ninja && ninja install

# Remove our working directory
RUN rm -rf /working

# Need nasm for libvpx
RUN apt-get install nasm

# The following steps setup a group and user to match outside permissions so we're not doing everything as root
RUN groupadd --gid $GROUP_ID user

# Gotta make the directory first or else useradd fails
RUN mkdir -p /home/user
RUN useradd --uid $USER_ID --gid $GROUP_ID --create-home user

# Give ourselves a password 'user' and add us to the sudo group
RUN echo "user:user" | chpasswd
RUN usermod -aG sudo user

# Make sure we have permissions to our own home directory
RUN chown user:user /home/user

USER user
