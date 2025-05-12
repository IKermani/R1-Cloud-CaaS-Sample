# Stage 1: Build Stage
FROM python:3.12-slim-bookworm AS builder

WORKDIR /app

# Copy only the requirements file to leverage Docker cache
COPY requirements.txt .

# Install dependencies and create wheel files
RUN pip wheel --no-cache-dir --wheel-dir=/wheels -r requirements.txt

# Stage 2: Production Stage
FROM python:3.12-slim-bookworm

WORKDIR /app

# Copy only the wheel files from the builder stage
COPY --from=builder /wheels /wheels

COPY requirements.txt .

# Install dependencies from wheel files
RUN pip install --no-cache-dir --find-links=/wheels -r requirements.txt

# Copy the rest of the application files
COPY src/ .

EXPOSE 8000

ENV DATABASE_URL="postgresql://app:password@127.0.0.1/app"

# Run app.py when the container launches
CMD ["gunicorn", "main:app", "-b", "0.0.0.0", "-k", "uvicorn.workers.UvicornWorker"]
