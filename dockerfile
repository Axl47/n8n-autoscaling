FROM node:20

# Install dependencies for Puppeteer and Whisper
RUN apt-get update && apt-get install -y --no-install-recommends \
    libatk1.0-0 \
    libatk-bridge2.0-0 \
    libcups2 \
    libdrm2 \
    libxkbcommon0 \
    libxcomposite1 \
    libxdamage1 \
    libxrandr2 \
    libasound2 \
    libpangocairo-1.0-0 \
    libpango-1.0-0 \
    libgbm1 \
    libnss3 \
    libxshmfence1 \
    ca-certificates \
    fonts-liberation \
    libappindicator3-1 \
    libgtk-3-0 \
    wget \
    xdg-utils \
    lsb-release \
    fonts-noto-color-emoji \
    ffmpeg \
    python3 \
    python3-pip \
    git && rm -rf /var/lib/apt/lists/*

# Install Chromium browser
RUN apt-get update && apt-get install -y chromium && \
    rm -rf /var/lib/apt/lists/*

# Install n8n and Puppeteer
RUN npm install -g n8n puppeteer
RUN npm install -g n8n-nodes-puppeteer
ENV N8N_CUSTOM_EXTENSIONS="/data/community-nodes"

# Install yt-dlp (latest)
RUN pip3 install yt-dlp --break-system-packages

RUN pip3 install requests --break-system-packages

# Install Faster-Whisper (with CTranslate2 and audio deps)
RUN pip3 install faster-whisper ffmpeg-python --break-system-packages

# Add npm global bin to PATH to ensure n8n executable is found
ENV PATH="/usr/local/lib/node_modules/n8n/bin:$PATH"

ENV N8N_LOG_LEVEL=info
ENV NODE_FUNCTION_ALLOW_EXTERNAL=ajv,ajv-formats,puppeteer
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium

# Expose the n8n port
EXPOSE 5678

# Create proper entrypoint scripts with shebang
RUN printf '#!/bin/sh\nexec n8n worker\n' > /worker && \
    printf '#!/bin/sh\nexec n8n webhook\n' > /webhook && \
    chmod +x /worker /webhook

# Start n8n (default command)
CMD ["n8n", "start"]
