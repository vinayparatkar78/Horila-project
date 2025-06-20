# ── STAGE 1: Build dependencies ───────────────────────────────────────────
FROM python:3.10-slim-bullseye AS builder

ENV PYTHONUNBUFFERED=1

WORKDIR /app

# Copy only requirements first to leverage Docker layer caching
COPY requirements.txt .

# Install build‑time deps, install Python packages, then clean up apt lists
RUN apt-get update \
    && apt-get install -y --no-install-recommends gcc libcairo2-dev \
    && pip install --no-cache-dir -r requirements.txt \
    && apt-get purge -y --auto-remove gcc \
    && rm -rf /var/lib/apt/lists/*

# ── STAGE 2: Final image ───────────────────────────────────────────────────
FROM python:3.10-slim-bullseye

ENV PYTHONUNBUFFERED=1

WORKDIR /app

# Copy installed packages from the builder image
COPY --from=builder /usr/local/lib/python3.10/site-packages /usr/local/lib/python3.10/site-packages

# Copy your app code
COPY . .

# Ensure your entrypoint is executable
RUN chmod +x entrypoint.sh

EXPOSE 8000

# Launch your Django dev server
CMD ["python3", "manage.py", "runserver"]
