# Basic
# docker buildx build --platform linux/amd64,linux/arm64 -t andwilley/workstations:basic --push \
#   --build-arg INSTALL_ARDUINO=false \
#   --build-arg INSTALL_HASKELL=false \
#   --build-arg INSTALL_JVM=true \
#   --build-arg INSTALL_OCAML=false \
#   --build-arg INSTALL_ZIG=true \
#   --build-arg INSTALL_SWIFT=false \
#   .

# Swift
# docker buildx build --platform linux/amd64,linux/arm64 -t andwilley/workstations:swift --push  \
#   --build-arg INSTALL_ARDUINO=false \
#   --build-arg INSTALL_HASKELL=false \
#   --build-arg INSTALL_JVM=false \
#   --build-arg INSTALL_OCAML=false \
#   --build-arg INSTALL_ZIG=false \
#   --build-arg INSTALL_SWIFT=true \
#   .

# FP
# docker buildx build --platform linux/amd64,linux/arm64 -t andwilley/workstations:fp --push \
#   --build-arg INSTALL_ARDUINO=false \
#   --build-arg INSTALL_HASKELL=true \
#   --build-arg INSTALL_JVM=false \
#   --build-arg INSTALL_OCAML=true \
#   --build-arg INSTALL_ZIG=false \
#   --build-arg INSTALL_SWIFT=false \
#   .

# Arduino
# docker buildx build --platform linux/amd64,linux/arm64 -t andwilley/workstations:arduino --push \
#   --build-arg INSTALL_ARDUINO=true \
#   --build-arg INSTALL_HASKELL=false \
#   --build-arg INSTALL_JVM=false \
#   --build-arg INSTALL_OCAML=false \
#   --build-arg INSTALL_ZIG=false \
#   --build-arg INSTALL_SWIFT=false \
#   .

# DOCKER_TAG=basic
# docker network create dev-net
# docker run -it -d --name workspace-$DOCKER_TAG \
#   -p 8080:8080 -p 2222:22 -p 3000:3000 --netowrk dev-net \
#   -v /var/run/docker.sock:/var/run/docker.sock \
#   -v ~/projects:/home/rafiki/projects \
#   andwilley/workstations:$DOCKER_TAG

# docker exec -it workspace-$DOCKER_TAG /bin/bash -l

# To run docker commands in the container:
# $ sudo chown root:daemon /var/run/docker.sock
# $ sudo adduser rafiki daemon
# then re-enter the container

FROM debian:bookworm-slim

# TODO: Include version numbers for these as well
ARG USER_NAME=rafiki
ARG INSTALL_ARDUINO=true
ARG INSTALL_HASKELL=true
ARG INSTALL_JVM=true
ARG INSTALL_OCAML=true
ARG INSTALL_ZIG=true
ARG INSTALL_SWIFT=true

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8
ENV HOME=/home/$USER_NAME

RUN apt update && apt install -y --no-install-recommends \
    apt-transport-https \
    build-essential \
    ca-certificates \
    cmake \
    curl \
    dpkg \
    gettext \
    git \
    gnupg \
    gpg \
    jq \
    libgmp-dev \
    libz3-dev \
    locales \
    m4 \
    tree \
    less \
    ninja-build \
    openssh-client \
    pkg-config \
    postgresql-client \
    procps \
    protobuf-compiler \
    python3 \
    python3-pip \
    python3-venv \
    rsync \
    sudo \
    tmux \
    unzip \
    wget \
    zip \
    zlib1g-dev && \
    install -m 0755 -d /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc && \
    chmod a+r /etc/apt/keyrings/docker.asc && \
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
      $(. /etc/os-release && echo "bookworm") stable" | \
      tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    apt update && \
    apt install docker-ce-cli docker-buildx-plugin docker-compose-plugin && \
    rm -rf /var/lib/apt/lists/* && \
    apt clean

# Always install CPP tooling
RUN echo "--- Installing Extra C/C++ Toolchain (Clang, etc) ---" && \
      apt update && apt install -y --no-install-recommends \
        gdb \
        clang \
        clangd \
        lldb \
      && rm -rf /var/lib/apt/lists/* && apt clean

# Configure locale settings.
RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=en_US.UTF-8

RUN useradd -m -s /bin/bash $USER_NAME && \
    echo "$USER_NAME:$USER_NAME" | chpasswd && \
    adduser $USER_NAME sudo && \
    chown -R $USER_NAME:$USER_NAME /home/$USER_NAME

RUN echo "--- Installing GCloud ---" && \
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && \
    apt update && apt install -y --no-install-recommends google-cloud-cli

USER $USER_NAME
WORKDIR $HOME

RUN mkdir -p ${HOME}/local/bin
ENV PATH="${HOME}/local/bin:${PATH}"

RUN git clone https://github.com/neovim/neovim.git --depth 1 --branch stable ${HOME}/neovim-src \
    && cd ${HOME}/neovim-src \
    && make CMAKE_BUILD_TYPE=Release CMAKE_INSTALL_PREFIX=${HOME}/local \
    && make install \
    && rm -rf ${HOME}/neovim-src

RUN mkdir -p ${HOME}/.config && \
    git clone --depth 1 --recurse-submodules https://github.com/andwilley/nvim-config.git ${HOME}/.config/nvim && \
    git clone --depth 1 --recurse-submodules https://github.com/andwilley/dotfiles.git /tmp/dotfiles && \
    rsync -av /tmp/dotfiles/ ${HOME}/ && \
    rm -rf /tmp/dotfiles

RUN git config --global --unset url."ssh://git@github.com/".insteadOf

RUN echo "--- Installing Starship ---" && \
    curl -sS https://starship.rs/install.sh | sh -s -- -y -b ${HOME}/local/bin

# Always install GO for building gh from src
SHELL ["/bin/bash", "-c"]
RUN echo "--- Installing Go ---" && \
      GO_VERSION=$(curl -s "https://go.dev/VERSION?m=text" | head -n 1) && \
      ARCH=$(dpkg --print-architecture) && \
      wget https://go.dev/dl/${GO_VERSION}.linux-${ARCH}.tar.gz -O go.tar.gz && \
      mkdir -p ${HOME}/go-sdk && \
      tar -C ${HOME}/go-sdk -xzf go.tar.gz --strip-components=1 && \
      ln -s ${HOME}/go-sdk/bin/go ${HOME}/local/bin/go && \
      ln -s ${HOME}/go-sdk/bin/gofmt ${HOME}/local/bin/gofmt && \
      rm go.tar.gz && \
      echo "--- Installing Git CLI ---" && \
      git clone https://github.com/cli/cli.git .gh-cli && \
      cd .gh-cli && \
      make install prefix=$HOME/local && \
      rm -rf .gh-cli && \
      go install golang.org/x/tools/gopls@latest && \
      go install github.com/fullstorydev/grpcurl/cmd/grpcurl@latest

# Always install node for gemini and bazelisk
SHELL ["/bin/bash", "-c"]
RUN echo "--- Installing Node.js ---" && \
      curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash && \
      export NVM_DIR="${HOME}/.nvm" && \
      [ -s "${NVM_DIR}/nvm.sh" ] && \. "${NVM_DIR}/nvm.sh" && \
      nvm install --lts && \
      nvm alias default lts/* && \
      NODE_PATH=$(dirname $(dirname $(nvm which current))) && \
      ln -s ${NODE_PATH}/bin/node ${HOME}/local/bin/node && \
      ln -s ${NODE_PATH}/bin/npm ${HOME}/local/bin/npm && \
      ln -s ${NODE_PATH}/bin/npx ${HOME}/local/bin/npx && \
      npm install -g typescript ts-node yarn pnpm @google/gemini-cli @bazel/bazelisk @anthropic-ai/claude-code && \
      ln -s ${NODE_PATH}/bin/tsc ${HOME}/local/bin/tsc && \
      ln -s ${NODE_PATH}/bin/ts-node ${HOME}/local/bin/ts-node && \
      ln -s ${NODE_PATH}/bin/yarn ${HOME}/local/bin/yarn && \
      ln -s ${NODE_PATH}/bin/pnpm ${HOME}/local/bin/pnpm && \
      ln -s ${NODE_PATH}/bin/gemini ${HOME}/local/bin/gemini && \
      ln -s ${NODE_PATH}/bin/claude ${HOME}/local/bin/claude && \
      ln -s ${NODE_PATH}/bin/bazel ${HOME}/local/bin/bazel && \
      ln -s ${NODE_PATH}/bin/bazelisk ${HOME}/local/bin/bazelisk

RUN if [ "${INSTALL_ARDUINO}" = "true" ]; then \
      echo "--- Installing Arduino Tools ---" && \
      curl -fsSL https://raw.githubusercontent.com/arduino/arduino-cli/master/install.sh | BINDIR=${HOME}/local/bin sh && \
      arduino-cli config init && \
      arduino-cli core update-index && \
      arduino-cli core install arduino:avr && \
      export GOCACHE=/tmp/.go-cache && \
      go install github.com/arduino/arduino-language-server@latest && \
      ln -s ${HOME}/go/bin/arduino-language-server ${HOME}/local/bin/arduino-language-server && \
      rm -rf /tmp/.go-cache; \
    fi

# Always install rust for JJ and Cargo
RUN echo "--- Installing Rust and jj ---" && \
      curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path && \
      ln -s ${HOME}/.cargo/bin/rustc ${HOME}/local/bin/ && \
      ln -s ${HOME}/.cargo/bin/cargo ${HOME}/local/bin/ && \
      ln -s ${HOME}/.cargo/bin/rustup ${HOME}/local/bin/ && \
      rustup component add rust-analyzer && \
      ${HOME}/.cargo/bin/cargo install jj-cli && \
      ln -s ${HOME}/.cargo/bin/jj ${HOME}/local/bin/ && \
      ${HOME}/.cargo/bin/rustup component remove rust-docs && \
      jj config set --user user.name "Drew Willey" && \
      jj config set --user user.email "andwilley@gmail.com" && \
      rm -rf ${HOME}/.cargo/registry/src/* && \
      rm -rf ${HOME}/.cargo/registry/index/*

# gopls is installed with go
RUN echo "--- Installing LSPs ---" && \
      git clone https://github.com/withered-magic/starpls.git ${HOME}/starpls && \
      cd ${HOME}/starpls && bazel run -c opt //editors/code:copy_starpls && \
      cd ~ && cp ${HOME}/starpls/editors/code/bin/starpls ${HOME}/local/bin/ && \
      rm -rf ${HOME}/starpls

RUN if [ "${INSTALL_JVM}" = "true" ]; then \
      echo "--- Installing JVM Tools ---" && \
      curl -s "https://get.sdkman.io" | bash; \
    fi
SHELL ["/bin/bash", "-l", "-c"]
RUN if [ "${INSTALL_JVM}" = "true" ]; then \
      source "${HOME}/.sdkman/bin/sdkman-init.sh" && \
      export sdkman_auto_answer=true && \
      sdk install java 21.0.7-tem && \
      sdk install kotlin && \
      sdk install gradle && \
      sdk install maven && \
      ln -s ${HOME}/.sdkman/candidates/java/current/bin/java ${HOME}/local/bin/ && \
      ln -s ${HOME}/.sdkman/candidates/java/current/bin/javac ${HOME}/local/bin/ && \
      ln -s ${HOME}/.sdkman/candidates/kotlin/current/bin/kotlin ${HOME}/local/bin/ && \
      ln -s ${HOME}/.sdkman/candidates/kotlin/current/bin/kotlinc ${HOME}/local/bin/ && \
      ln -s ${HOME}/.sdkman/candidates/gradle/current/bin/gradle ${HOME}/local/bin/ && \
      ln -s ${HOME}/.sdkman/candidates/maven/current/bin/mvn ${HOME}/local/bin/; \
    fi

RUN if [ "${INSTALL_HASKELL}" = "true" ]; then \
      echo "--- Installing Haskell ---" && \
      curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | BOOTSTRAP_HASKELL_MINIMAL=1 BOOTSTRAP_HASKELL_INSTALL_HLS=1 sh -s -- -c && \
      export PATH="${HOME}/.ghcup/bin:${PATH}" && \
      ghcup install ghc recommended && \
      ghcup set ghc recommended && \
      ghcup install cabal recommended && \
      ghcup install hls recommended && \
      ln -s ${HOME}/.ghcup/bin/ghc ${HOME}/local/bin/ && \
      ln -s ${HOME}/.ghcup/bin/cabal ${HOME}/local/bin/ && \
      ln -s ${HOME}/.ghcup/bin/haskell-language-server-wrapper ${HOME}/local/bin/hls && \
      ln -s ${HOME}/.ghcup/bin/ghcup ${HOME}/local/bin/ && \
      cabal update && \
      rm -rf ${HOME}/.ghcup/tmp && \
      rm -rf ${HOME}/.cabal/packages; \
    fi

SHELL ["/bin/bash", "-c"]
RUN if [ "${INSTALL_OCAML}" = "true" ]; then \
      echo "--- Installing OCaml ---" && \
      ARCH=$(dpkg --print-architecture) && \
      if [ "${ARCH}" = "amd64" ]; then OPAM_ARCH="x86_64"; else OPAM_ARCH="arm64"; fi && \
      curl -fsSLo ${HOME}/local/bin/opam "https://github.com/ocaml/opam/releases/download/2.2.0/opam-2.2.0-${OPAM_ARCH}-linux" && \
      chmod +x ${HOME}/local/bin/opam && \
      opam init --disable-sandboxing -y && \
      . ${HOME}/.opam/opam-init/init.sh && \
      opam install -y utop ocaml-lsp-server ocamlformat odoc dune merlin; \
    fi

RUN if [ "${INSTALL_ZIG}" = "true" ]; then \
      echo "--- Installing Zig ---" && \
      ARCH=$(dpkg --print-architecture) && \
      if [ "${ARCH}" = "amd64" ]; then ZIG_ARCH="x86_64-linux"; else ZIG_ARCH="aarch64-linux"; fi && \
      LATEST_ZIG_URL=$(curl -s https://ziglang.org/download/index.json | jq -r ".master.\"${ZIG_ARCH}\".tarball") && \
      wget ${LATEST_ZIG_URL} -O zig.tar.xz && \
      mkdir -p ${HOME}/local/zig-compiler && \
      tar -xf zig.tar.xz -C ${HOME}/local/zig-compiler --strip-components=1 && \
      rm zig.tar.xz && \
      ln -s ${HOME}/local/zig-compiler/zig ${HOME}/local/bin/zig; \
    fi

# Note that this will override the existing cpp tooling and map it all to swiftly.
RUN if [ "${INSTALL_SWIFT}" = "true" ]; then \
      echo "--- Installing Swift ---" && \
      curl -O https://download.swift.org/swiftly/linux/swiftly-$(uname -m).tar.gz && \
      tar zxf swiftly-$(uname -m).tar.gz && \
      ./swiftly init --verbose --assume-yes; \
    fi

# Restore git config
RUN git config --global url."ssh://git@github.com/".insteadOf https://github.com/

SHELL ["/bin/bash", "-c"]

ENTRYPOINT ["/bin/bash", "-l"]
