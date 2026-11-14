# Dockerfile untuk FruitLens AI Backend (FastAPI + MobileNetV3 + SVM)
FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

WORKDIR /app

# Install dependency sistem untuk OpenCV headless & image processing
RUN apt-get update && apt-get install -y --no-install-recommends \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender-dev \
    && rm -rf /var/lib/apt/lists/*

# Salin requirements dan install
COPY backend/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt opencv-python-headless

# Salin kode backend dan model pkl
COPY backend/ /app/backend/
COPY baca/svm_pisang_3kelas(96%).pkl /app/baca/

WORKDIR /app/backend

EXPOSE 8000

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]

