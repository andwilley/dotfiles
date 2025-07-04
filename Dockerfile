# Use the latest Debian Long Term Support (LTS) release as the base image.
# bookworm is the current LTS as of late 2023/early 2024.
FROM debian:bookworm-slim

# --- Build Arguments ---
# Use these flags during `docker build` to skip heavy installations.
# e.g., docker build --build-arg INSTALL_RUST=false .
ARG USER_NAME=dev
ARG INSTALL_CPP=true
ARG INSTALL_RUST=true
ARG INSTALL_HASKELL=true
ARG INSTALL_NODE=true
ARG INSTALL_JVM=true
ARG INSTALL_OCAML=true
ARG INSTALL_ZIG=true

# Pass build-time ARGs to runtime ENV variables for use in CMD.
ENV _USER_NAME=${USER_NAME}
ENV _INSTALL_CPP=${INSTALL_CPP}
ENV _INSTALL_RUST=${INSTALL_RUST}
ENV _INSTALL_HASKELL=${INSTALL_HASKELL}
ENV _INSTALL_NODE=${INSTALL_NODE}
ENV _INSTALL_JVM=${INSTALL_JVM}
ENV _INSTALL_OCAML=${INSTALL_OCAML}
ENV _INSTALL_ZIG=${INSTALL_ZIG}

# Set environment variables to non-interactive to prevent prompts during installation.
ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8
ENV HOME=/home/$USER_NAME

# Install base dependencies, build tools, and essential utilities.
# These are required for all subsequent build steps, including Neovim.
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    git \
    gnupg \
    jq \
    locales \
    m4 \
    procps \
    rsync \
    sudo \
    tmux \
    unzip \
    wget \
    zip \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# Conditionally install C/C++ Toolchain (GCC, Clang, build tools)
RUN if [ "${INSTALL_CPP}" = "true" ]; then \
      echo "--- Installing C/C++ Toolchain ---" && \
      apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        cmake \
        gdb \
        clang \
        clangd \
        lldb \
        ninja-build \
        pkg-config \
        libgmp-dev \
        zlib1g-dev \
      && rm -rf /var/lib/apt/lists/* && apt-get clean; \
    else \
      apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        cmake \
        gettext \
        ninja-build \
        pkg-config \
        libgmp-dev \
        zlib1g-dev \
      && rm -rf /var/lib/apt/lists/* && apt-get clean; \
    fi


# Configure locale settings.
RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=en_US.UTF-8

# Create a non-root user for security and set it up.
RUN useradd -m -s /bin/bash dev && \
    echo "dev:dev" | chpasswd && \
    adduser dev sudo

# Switch to the non-root user.
USER $USER_NAME
WORKDIR $HOME

# Set up a local bin directory and add it to the PATH.
# This will be the single location for all user-installed binaries.
RUN mkdir -p ${HOME}/local/bin
ENV PATH="${HOME}/local/bin:${PATH}"

# --- Language & Tooling Installations ---

# The following sections will be executed as the passed user.

# Build and install the latest stable Neovim from source as non-root.
# It will be installed directly into ${HOME}/local.
RUN git clone https://github.com/neovim/neovim.git --depth 1 --branch stable ${HOME}/neovim-src \
    && cd ${HOME}/neovim-src \
    && make CMAKE_BUILD_TYPE=Release CMAKE_INSTALL_PREFIX=${HOME}/local \
    && make install \
    && rm -rf ${HOME}/neovim-src

# --- Personal Environment Setup ---
# Clone personal dotfiles and nvim configuration, including submodules.
# This is done early so subsequent steps can leverage the configured shell environment.
RUN mkdir -p ${HOME}/.config && \
    git clone --depth 1 --recurse-submodules https://github.com/andwilley/nvim-config.git ${HOME}/.config/nvim && \
    git clone --depth 1 --recurse-submodules https://github.com/andwilley/dotfiles.git /tmp/dotfiles && \
    rsync -av /tmp/dotfiles/ ${HOME}/ && \
    rm -rf /tmp/dotfiles

# Install Starship prompt
RUN curl -sS https://starship.rs/install.sh | sh -s -- -y -b ${HOME}/local/bin

# Conditionally install NVM, Node.js, and global packages, then symlink binaries.
SHELL ["/bin/bash", "-c"]
RUN if [ "${INSTALL_NODE}" = "true" ]; then \
      echo "--- Installing Node.js ---" && \
      curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash && \
      export NVM_DIR="${HOME}/.nvm" && \
      [ -s "${NVM_DIR}/nvm.sh" ] && \. "${NVM_DIR}/nvm.sh" && \
      nvm install --lts && \
      nvm alias default lts/* && \
      NODE_PATH=$(dirname $(dirname $(nvm which current))) && \
      ln -s ${NODE_PATH}/bin/node ${HOME}/local/bin/node && \
      ln -s ${NODE_PATH}/bin/npm ${HOME}/local/bin/npm && \
      ln -s ${NODE_PATH}/bin/npx ${HOME}/local/bin/npx && \
      npm install -g typescript ts-node yarn pnpm && \
      ln -s ${NODE_PATH}/bin/tsc ${HOME}/local/bin/tsc && \
      ln -s ${NODE_PATH}/bin/ts-node ${HOME}/local/bin/ts-node && \
      ln -s ${NODE_PATH}/bin/yarn ${HOME}/local/bin/yarn && \
      ln -s ${NODE_PATH}/bin/pnpm ${HOME}/local/bin/pnpm; \
    fi

# Conditionally install Rust via rustup, jj, symlink binaries, and then clean up.
RUN if [ "${INSTALL_RUST}" = "true" ]; then \
      echo "--- Installing Rust and jj ---" && \
      curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path && \
      ln -s ${HOME}/.cargo/bin/rustc ${HOME}/local/bin/ && \
      ln -s ${HOME}/.cargo/bin/cargo ${HOME}/local/bin/ && \
      ln -s ${HOME}/.cargo/bin/rustup ${HOME}/local/bin/ && \
      ${HOME}/.cargo/bin/cargo install jj-cli && \
      ln -s ${HOME}/.cargo/bin/jj ${HOME}/local/bin/ && \
      ${HOME}/.cargo/bin/rustup component remove rust-docs && \
      rm -rf ${HOME}/.cargo/registry/src/* && \
      rm -rf ${HOME}/.cargo/registry/index/*; \
    fi

# Conditionally install SDKMAN!, JVM languages, symlink binaries.
RUN if [ "${INSTALL_JVM}" = "true" ]; then \
      echo "--- Installing JVM Tools ---" && \
      curl -s "https://get.sdkman.io" | bash; \
    fi
SHELL ["/bin/bash", "-l", "-c"]
RUN if [ "${INSTALL_JVM}" = "true" ]; then \
      source "${HOME}/.sdkman/bin/sdkman-init.sh" && \
      sdk install java && \
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

# Conditionally install GHCup for Haskell, symlink binaries, and apply optimizations.
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

# Conditionally install OCaml and OPAM
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

# Conditionally install Zig into local directory and symlink binary.
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

# --- Final Configuration ---

# Reset shell to default for CMD and ENTRYPOINT
SHELL ["/bin/bash", "-c"]

# Set the entrypoint to bash with a login shell to ensure all env variables are loaded.
ENTRYPOINT ["/bin/bash", "-l"]

# CMD /bin/bash

# Final message to show upon container start.
# CMD echo "Cloud developer workstation ready. Welcome!" && echo "Installed tools:" && \
#     echo " - Neovim: $(nvim --version | head -n 1)" && \
#     if [ "${_INSTALL_RUST}" = "true" ]; then echo " - jj: $(jj --version | head -n 1)"; fi && \
#     echo " - tmux: $(tmux -V)" && \
#     echo " - Starship: $(starship --version | head -n 1)" && \
#     if [ "${_INSTALL_NODE}" = "true" ]; then echo " - Node.js (LTS): $(node --version)"; fi && \
#     if [ "${_INSTALL_NODE}" = "true" ]; then echo " - npm (LTS): $(npm --version)"; fi && \
#     if [ "${_INSTALL_NODE}" = "true" ]; then echo " - TypeScript: $(tsc --version)"; fi && \
#     if [ "${_INSTALL_RUST}" = "true" ]; then echo " - Rust: $(rustc --version)"; fi && \
#     if [ "${_INSTALL_JVM}" = "true" ]; then echo " - Java: $(java --version | head -n 1)"; fi && \
#     if [ "${_INSTALL_JVM}" = "true" ]; then echo " - Kotlin: $(kotlin -version | head -n 1)"; fi && \
#     if [ "${_INSTALL_HASKELL}" = "true" ]; then echo " - GHC (Haskell): $(ghc --version)"; fi && \
#     if [ "${_INSTALL_HASKELL}" = "true" ]; then echo " - Cabal (Haskell): $(cabal --version | head -n 1)"; fi && \
#     if [ "${_INSTALL_OCAML}" = "true" ]; then echo " - OCaml: $(ocaml -version)"; fi && \
#     if [ "${_INSTALL_ZIG}" = "true" ]; then echo " - Zig: $(zig version)"; fi && \
#     if [ "${_INSTALL_CPP}" = "true" ]; then echo " - C/C++ (GCC): $(gcc --version | head -n 1)"; fi && \
#     if [ "${_INSTALL_CPP}" = "true" ]; then echo " - C/C++ (Clang): $(clang --version | head -n 1)"; fi && \
#     /bin/bash
