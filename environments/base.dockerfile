ARG NAUTOBOT_VERSION
ARG PYTHON_VERSION


# #############################################################################
# Stage: Base image
# -----------------------------------------------------------------------------
FROM ghcr.io/nautobot/nautobot:${NAUTOBOT_VERSION}-py${PYTHON_VERSION} as nautobot-base

USER 0

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get autoremove -y && \
    apt-get clean all && \
    rm -rf /var/lib/apt/lists/* && \
    pip --no-cache-dir install --upgrade pip wheel


# #############################################################################
# Stage: Builder
# -----------------------------------------------------------------------------
FROM ghcr.io/nautobot/nautobot-dev:${NAUTOBOT_VERSION}-py${PYTHON_VERSION} as builder
ARG NAUTOBOT_VERSION
ARG PYTHON_SUPPORTED_RANGE

CMD ["nautobot-server", "runserver", "0.0.0.0:8080", "--insecure"]

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get autoremove -y && \
    apt-get clean all && \
    rm -rf /var/lib/apt/lists/*

# -----------------------------------------------------------------------------
# Configuration for development
# -----------------------------------------------------------------------------
WORKDIR /opt/nautobot
COPY ../jobs /opt/nautobot/jobs
COPY ../config/nautobot_config.py /opt/nautobot/nautobot_config.py

# -----------------------------------------------------------------------------
# Nautobot dev project
# -----------------------------------------------------------------------------
WORKDIR /source
RUN pwd && \
    echo ------------------------------------------ && \
    python --version && \
    poetry --version && \
    echo PYTHON_SUPPORTED_RANGE ${PYTHON_SUPPORTED_RANGE} && \
    echo ------------------------------------------ && \
    poetry init --no-interaction \
                --name="nautobot-docker-compose" \
                --author="Network to Code LLC" \
                --python="${PYTHON_SUPPORTED_RANGE}" && \
    poetry add "nautobot==${NAUTOBOT_VERSION}" && \
    poetry install --no-interaction --no-ansi && \
    mkdir /tmp/dist && \
    poetry export --without-hashes -o /tmp/dist/requirements.txt

# NOTES:
# - Seems that nothing happens with the exported requirements.txt file
# - Nautobot is already installed so there is no need to poetry add
# - Or as in the original code poetry install since only add invoke and toml
#   this two last are a requirement for the host seems not used on the container
# - Exporting the requirements.txt seems useless

# -----------------------------------------------------------------------------
# Plugins
# -----------------------------------------------------------------------------
# COPY ../plugins /source/plugins
# RUN for plugin in /source/plugins/*; do \
#        cd $plugin && \
#        poetry build && \
#        cp dist/*.whl /tmp/dist; \
#    done


# #############################################################################
# Final Image
# -----------------------------------------------------------------------------
FROM nautobot-base as nautobot
ARG PYTHON_VERSION

COPY --from=builder /opt/nautobot /opt/nautobot

# NOTE: Seems useful only if a plugin was built
# Copy *.whl generated and requirements.txt
# COPY --from=builder /tmp/dist/*.whl /tmp/dist/requirements.txt /tmp/dist/

# NOTE: This is dirty has hell, what is the purpose of this two COPY command?
# Copy from base the required python libraries and binaries
COPY --from=builder /usr/local/lib/python${PYTHON_VERSION}/site-packages /usr/local/lib/python${PYTHON_VERSION}/site-packages
COPY --from=builder /usr/local/bin /usr/local/bin

# Verify that pyuwsgi was installed correctly, i.e. with SSL support
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN pyuwsgi --cflags | sed 's/ /\n/g' | grep -e "^-DUWSGI_SSL$"

USER nautobot

WORKDIR /opt/nautobot

# NOTE: No CMD or ENTRYPOINT to use the original ENTRYPOINT

# vim: set ft=dockerfile :
