FROM python:3.11-slim

WORKDIR /opt/app

# Install system deps you need (edit as required)
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential && \
    rm -rf /var/lib/apt/lists/*

# Leverage layer caching: copy only dependency files first
COPY requirements.txt* pyproject.toml* poetry.lock* ./

# Install dependencies (handles either requirements.txt or pyproject.toml)
RUN --mount=type=cache,target=/root/.cache/pip \
    if [ -f requirements.txt ]; then pip install --no-cache-dir -r requirements.txt; fi && \
    if [ -f pyproject.toml ]; then pip install --no-cache-dir .; fi

# Now copy the rest of the source
COPY . .

# Run as non-root
RUN useradd -m appuser && chown -R appuser:appuser /opt/app
USER appuser

# Set your default command
CMD ["python", "-m", "your_module"]

