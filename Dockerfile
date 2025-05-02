# Gunakan image Python resmi
FROM python:3.10-slim

# Atur direktori kerja
WORKDIR /app

# Salin file ke container
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

# Jalankan aplikasi Flask
CMD ["python", "server.py"]
