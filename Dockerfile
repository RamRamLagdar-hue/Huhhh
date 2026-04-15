# Shifted from Alpine to Debian Slim for better networking and glibc wheel compatibility
FROM python:3.12-slim

# Set the working directory
WORKDIR /app

# Install necessary system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    ffmpeg \
    aria2 \
    wget \
    unzip \
    && wget -q https://github.com/axiomatic-systems/Bento4/archive/v1.6.0-639.zip \
    && unzip v1.6.0-639.zip \
    && cd Bento4-1.6.0-639 \
    && mkdir build \
    && cd build \
    && cmake .. \
    && make -j$(nproc) \
    && cp mp4decrypt /usr/local/bin/ \
    && cd ../.. \
    && rm -rf Bento4-1.6.0-639 v1.6.0-639.zip \
    && apt-get purge -y build-essential cmake wget unzip \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*

# Copy all files from the current directory to the container's /app directory
COPY . .

# Install Python dependencies
# Explicitly installing TgCrypto (vital for Pyrogram speed)
RUN pip3 install --no-cache-dir --upgrade pip \
    && pip3 install --no-cache-dir --upgrade -r requirements.txt \
    && pip3 install --no-cache-dir TgCrypto cryptg yt-dlp

# Set the command to run the application
CMD ["sh", "-c", "gunicorn app:app & python3 modules/main.py"]
