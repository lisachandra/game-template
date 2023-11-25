FROM mcr.microsoft.com/devcontainers/base:ubuntu

WORKDIR /usr/local/bin

RUN apt-get update && apt-get install -y wget unzip

RUN wget https://github.com/Roblox/foreman/releases/latest/download/foreman-linux.zip && \
    unzip foreman-linux.zip && \
    rm foreman-linux.zip && \
    chmod +x /usr/local/bin/foreman

ENV PATH="/root/.foreman/bin:/usr/local/bin:${PATH}"
