ARG MOQUI_IMAGE=moqui:latest
FROM ${MOQUI_IMAGE}

USER root

# curl and certificates are useful for health checks and outbound HTTPS calls.
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       curl ca-certificates \
       python3 python3-venv python3-pip python3-dev build-essential \
    && rm -rf /var/lib/apt/lists/*

ARG JEP_VERSION=4.3.1
ARG NUMPY_VERSION=

ENV MOQUI_HOME=/opt/moqui
ENV VENV_DIR=/opt/moqui/runtime/python_venv
ENV PYTHONNOUSERSITE=1
ENV PYTHONPATH=
ENV REQUIRE_JEP=true

RUN python3 -m venv "${VENV_DIR}" \
    && "${VENV_DIR}/bin/python" -m pip install --upgrade pip \
    && if [ -n "${NUMPY_VERSION}" ]; then \
         "${VENV_DIR}/bin/pip" install --no-cache-dir "numpy==${NUMPY_VERSION}"; \
       else \
         "${VENV_DIR}/bin/pip" install --no-cache-dir numpy; \
       fi \
    && "${VENV_DIR}/bin/pip" install --no-cache-dir "jep==${JEP_VERSION}"

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
