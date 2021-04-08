# See here for image contents: https://github.com/microsoft/vscode-dev-containers/tree/v0.158.0/containers/cpp/.devcontainer/base.Dockerfile

# [Choice] Debian / Ubuntu version: debian-10, debian-9, ubuntu-20.04, ubuntu-18.04
ARG VARIANT="buster"
FROM mcr.microsoft.com/vscode/devcontainers/cpp:0-${VARIANT}

RUN \
  # Common packages
  export DEBIAN_FRONTEND=noninteractive \
  && apt-get update \
  && apt-get -y install --no-install-recommends \
    pkg-config \
    direnv \
    vim \
    bash-completion \
    clang-format \
    clang-tidy \
    clang-tools \
    iwyu \
    tree \
  # Clean up
  && apt-get autoremove -y \
  && apt-get clean -y \
  && rm -rf /var/lib/apt/lists/*

COPY anyenv.sh /etc/profile.d/01-anyenv.sh

RUN \
  # direnv
  echo 'eval "$(direnv hook bash)"' >> /etc/profile.d/10-direnv.sh \
  # anyenv
  && git clone https://github.com/anyenv/anyenv /opt/anyenv \
  && update-alternatives --install /usr/bin/anyenv anyenv /opt/anyenv/bin/anyenv 100 \
  && . /etc/profile \
  && anyenv install --force-init \
  # pyenv
  && anyenv install pyenv
RUN \
  . /etc/profile \
  # pyenv-virtualenv
  && git clone https://github.com/pyenv/pyenv-virtualenv.git $(pyenv root)/plugins/pyenv-virtualenv \
  && echo 'eval "$(pyenv virtualenv-init -)"' >> /etc/profile.d/02-pyenv-virtualenv.sh \
  # python
  && export DEBIAN_FRONTEND=noninteractive \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
    build-essential libssl-dev zlib1g-dev libbz2-dev \
    libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev libncursesw5-dev \
    xz-utils tk-dev libffi-dev liblzma-dev python-openssl git \
  && PYTHON_CONFIGURE_OPTS="--enable-shared" pyenv install 3.7.10 \
  && pyenv global 3.7.10 \
  # Clean up
  && apt-get autoremove -y \
  && apt-get clean -y \
  && rm -rf /var/lib/apt/lists/*
RUN \
  . /etc/profile \
  # install cpp devtools using pip and venv-cpp-devtools virtualenv
  && pyenv virtualenv 3.7.10 venv-cpp-devtools \
  && pyenv activate venv-cpp-devtools \
  && pip install -q --upgrade --no-cache-dir pip \
  && pip install -q --no-cache-dir \
    cmake \
    cmakelang[YAML] \
    conan \
    conan-package-tools \
  && pyenv rehash \
  # remove all __pycache__ directories created by pyenv
  && find $(pyenv root) -iname __pycache__ -print0 | xargs -0 rm -rf \
  # conan bash completion
  && curl -Ls -o /etc/bash_completion.d/conan-completion \
    https://gitlab.com/akim.saidani/conan-bashcompletion/-/raw/master/conan-completion

USER vscode
RUN \
  # conan profile
  . /etc/profile \
  && pyenv activate venv-cpp-devtools \
  && conan profile new default --detect \
  && conan profile new clang --detect \
  && conan profile update settings.compiler.libcxx=libstdc++11 default \
  && conan profile update settings.compiler.libcxx=libstdc++11 clang \
  && conan profile update settings.compiler=clang clang \
  && conan profile update settings.compiler.version=7.0 clang \
  && conan profile update env.CC=/usr/bin/clang clang \
  && conan profile update env.CXX=/usr/bin/clang++ clang


ENV EDITOR vim
ENV PIP_REQUIRE_VIRTUALENV true
ENV CPM_SOURCE_CACHE ~/.cache/CPM
