# syntax=docker/dockerfile:1.7
FROM python:3.11-slim

# syntax=docker/dockerfile:1.7
FROM python:3.11-slim

# ---- build args you can override at build time ----
ARG REPO_URL="https://github.com/MarkAStevens04/PHY245_Labs.git"
ARG REF=main
ARG APP_DIR=/opt/app
ARG APP_CMD="python -m your_module"\

# Install OS deps (git and compilers for common Python wheels); then clean up
RUN apt-get update && apt-get install -y --no-install-recommends \
    git build-essential && \
    rm -rf /var/lib/apt/lists/*

# Optional: enable BuildKit pip cache for faster rebuilds
# (works because we used "# syntax=docker/dockerfile:1.7" above)
RUN --mount=type=cache,target=/root/.cache/pip \
    git clone --depth 1 --branch "$REF" "$REPO_URL" "$APP_DIR" && \
    cd "$APP_DIR" && \
    if [ -f requirements.txt ]; then pip install --no-cache-dir -r requirements.txt; fi && \
    if [ -f pyproject.toml ]; then pip install --no-cache-dir .; fi

WORKDIR $APP_DIR

# Run as a non-root user
RUN useradd -m appuser && chown -R appuser:appuser "$APP_DIR"
USER appuser

# Use shell-form so $APP_CMD is expanded at runtime
CMD bash -lc "$APP_CMD"
