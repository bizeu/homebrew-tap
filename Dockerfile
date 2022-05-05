# syntax=docker/dockerfile:1
FROM homebrew/brew:latest AS brew

# Build
# export DOCKER_BUILDKIT=1 or daemon.json: { "features": { "buildkit": true } }
# docker build --ssh default=~/.ssh/id_rsa .

RUN apt update -qq
RUN apt install -y openssh-client git

# Download public key for github.com
RUN --mount=type=ssh mkdir -p -m 0600 ~/.ssh && ssh-keyscan github.com >> ~/.ssh/known_hosts

# Clone private repository
RUN --mount=type=ssh git clone git@github.com:j5pux/config.git config
