FROM ruby:3.4.3-slim

ENV LANG=C.UTF-8 \
    TZ=Asia/Tokyo \
    PLAYWRIGHT_BROWSERS_PATH=/ms-playwright

RUN apt-get update -qq && apt-get install -y --no-install-recommends \
      build-essential \
      ca-certificates \
      curl \
      ffmpeg \
      git \
      gh \
      gnupg2 \
      imagemagick \
      libheif-dev \
      libpq-dev \
      libuv1-dev \
      libvips-dev \
      libyaml-dev \
      postgresql-client \
      tzdata && \
    curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && \
    apt-get update -qq && apt-get install -y --no-install-recommends nodejs && \
    npm install --global @openai/codex && \
    gem update --system && \
    gem install --no-document bundler -v 2.7.2 && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /tmp/playwright
COPY package.json package-lock.json ./
RUN npm ci && \
    npx playwright install --with-deps chromium && \
    rm -rf /tmp/playwright

ENV BUNDLE_PATH=/var/lib/codex-bootcamp/bundle

RUN useradd --create-home --uid 1000 codex

WORKDIR /workspace
USER codex

CMD ["bin/codex-issue-automation"]
