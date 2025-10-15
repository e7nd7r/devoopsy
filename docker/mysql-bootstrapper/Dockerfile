# MySQL client/tooling bootstrap image
#
# Purpose:
#   This Dockerfile builds a small Oracle Linux based image that contains
#   MySQL client tooling (mysql client, mysqlsh) and several helper tools
#   (aws cli v2, aws_signing_helper, curl, etc.). It's intended to be used
#   as a bootstrap/runtime image for provisioning or initializing MySQL
#   databases (e.g., running schema migrations, importing data, or running
#   one-off administrative scripts), not as a MySQL server container.
#
# Build:
#   docker build -t devoopsy/mysql-bootstrapper:latest \
#     --build-arg TARGETARCH=amd64 \
#     -f docker/mysql-bootstrapper/Dockerfile docker/mysql-bootstrapper
#
# Run (example):
#   docker run --rm -ti devoopsy/mysql-bootstrapper:latest mysql -h <host> -u <user> -p
#   docker run --rm -ti devoopsy/mysql-bootstrapper:latest mysqlsh --uri user@host
#
# Important notes:
#   - This is a client-only image. It does NOT include a MySQL server.
#   - The Dockerfile accepts a build-arg TARGETARCH (amd64 | arm64) used to
#     select appropriate architecture-specific binaries (mysql-shell, aws cli).
#   - The image downloads pre-built RPMs and binaries from upstream vendors;
#     ensure you trust the sources and pin versions when necessary.
#   - Intended for use in CI/CD or administrative tasks where having a
#     pre-bundled client environment is helpful.
#
# Maintenance:
#   - Update pinned upstream versions (mysql-shell, aws cli, rolesanywhere)
#     in the Dockerfile when necessary and rebuild images.
#


FROM oraclelinux:9

ARG TARGETARCH

# Figure out arch once
RUN set -eux; \
  case "${TARGETARCH}" in \
    "amd64") echo x86_64  > /tmp/rpm_arch ;; \
    "arm64") echo aarch64 > /tmp/rpm_arch ;; \
    *) echo "Unsupported arch: ${TARGETARCH}." >&2; exit 1 ;; \
  esac;

# Add MySQL Yum repo (EL9) — use dnf, fallback to yum
RUN set -eux; \
  PM="dnf"; command -v dnf >/dev/null 2>&1 || PM="yum"; \
  $PM -y install https://dev.mysql.com/get/mysql84-community-release-el9-1.noarch.rpm; \
  $PM clean all || true

# Install **client-only** tools and base deps — use dnf, fallback to yum
RUN set -eux; \
  PM="dnf"; command -v dnf >/dev/null 2>&1 || PM="yum"; \
  $PM -y install \
    mysql-community-client \
    curl unzip python3 pip ca-certificates gzip \
    gettext ncurses-term \
    ; \
  $PM clean all || true

RUN set -eux; \
    python3 -m pip install tqdm;

# Install mysqlsh from the MySQL archives RPM (arch-aware)
RUN set -eux; \
  RPM_ARCH="$(cat /tmp/rpm_arch)"; \  
  curl -fSL -o /tmp/mysql-shell.rpm \
    "https://downloads.mysql.com/archives/get/p/43/file/mysql-shell-8.0.36-1.el9.${RPM_ARCH}.rpm"; \
  rpm -ivh /tmp/mysql-shell.rpm; \
  rm -f /tmp/mysql-shell.rpm;

# Install AWS CLI v2 (arch-aware)
RUN set -eux; \
  RPM_ARCH="$(cat /tmp/rpm_arch)"; \  
  curl -fSL -o /tmp/awscliv2.zip "https://awscli.amazonaws.com/awscli-exe-linux-${RPM_ARCH}.zip"; \
  unzip /tmp/awscliv2.zip -d /tmp; \
  /tmp/aws/install; \
  rm -rf /tmp/aws /tmp/awscliv2.zip;

# (3) aws_signing_helper (IAM Roles Anywhere)
# Official release provides static binaries per-arch; install to PATH
RUN set -eux; \
  RPM_ARCH="$(cat /tmp/rpm_arch)"; \
  case "$RPM_ARCH" in \
    x86_64) RA_URL="https://rolesanywhere.amazonaws.com/releases/1.7.1/X86_64/Linux/Amzn2023/aws_signing_helper" ;; \
    aarch64)  RA_URL="https://rolesanywhere.amazonaws.com/releases/1.7.1/Aarch64/Linux/Amzn2023/aws_signing_helper"  ;; \
    *) echo "Unsupported RA arch: $RA_ARCH" >&2; exit 1 ;; \
  esac; \
  curl -fsSL -o /usr/local/bin/aws_signing_helper "$RA_URL"; \
  chmod +x /usr/local/bin/aws_signing_helper

