# syntax=docker/dockerfile:1

# Global ARG declarations (available to the entire Dockerfile)
ARG PROJ=twp

# Stage 1: Base image.
FROM amazonlinux:2023.6.20241031.0 AS base

# Local ARG declarations
ARG PROJ

# Install the essential system packages.
RUN dnf install -y wget tar gzip python3-pip shadow-utils openssl nginx

# Create a non-privileged user
RUN useradd -r -s /usr/sbin/nologin ${PROJ}

# Install Supervisor.
RUN python3 -m pip install supervisor

# Create necessary directories for Nginx and set permissions
RUN set -x \
  && mkdir -p /opt/nginx/{log,conf,system} \
  && chown -R ${PROJ}:${PROJ} /opt/nginx

# Create necessary directories for app and set permissions
RUN set -x \
  && mkdir -p /opt/twp/cdn/{src,data,log,conf,system} \
  && chown -R ${PROJ}:${PROJ} /opt/twp

# Stage 2: Development image
FROM base AS dev

# Install the system packages required for debugging.
RUN dnf install -y less procps net-tools iputils bind-utils vim-minimal

# Copy source from host to container
COPY --from=src . /opt/twp/cdn/src

# Set default work directory.
WORKDIR /opt/nginx