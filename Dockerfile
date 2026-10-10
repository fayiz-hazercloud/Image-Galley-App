FROM python:3.10-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
RUN pip install --no-cache-dir PyMySQL gunicorn

# Create dedicated non-root user with a home directory
RUN groupadd -r appgroup && useradd -r -g appgroup -d /home/appuser -m appuser
RUN mkdir -p app/static/uploads && chown -R appuser:appgroup /app /home/appuser

# Copy application files and transfer ownership
COPY --chown=appuser:appgroup . .

# Run as non-root
USER appuser
ENV HOME=/home/appuser

EXPOSE 5000

# --preload loads app code once in master before forking workers
CMD ["gunicorn", "--preload", "--workers=2", "--bind=0.0.0.0:5000", "run:app"]
