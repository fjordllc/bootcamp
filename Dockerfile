# Build stage - includes devDependencies for asset compilation
FROM ruby:3.4.3-slim as builder

ENV RAILS_ENV production
WORKDIR /app

# Update rubygems
RUN gem update --system
RUN printf "install: --no-rdoc --no-ri\nupdate:  --no-rdoc --no-ri" > ~/.gemrc
RUN gem install --no-document --force bundler -v 2.4.21

# Install build dependencies with minimal footprint
RUN apt-get update -qq && apt-get install -y --no-install-recommends \
      build-essential \
      git \
      postgresql-client \
      libpq-dev \
      tzdata \
      curl \
      gnupg2 \
      libyaml-dev \
      ca-certificates \
      libvips-dev && \
    rm -rf /var/lib/apt/lists/*

# Install Node.js 22.x
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && \
    apt-get update && \
    apt-get install -y --no-install-recommends nodejs && \
    rm -rf /var/lib/apt/lists/*

# Set timezone
RUN ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime

# Install ALL npm packages (including devDependencies for asset compilation)
COPY package.json package-lock.json ./
RUN npm install

# Install gems
COPY Gemfile Gemfile.lock ./
RUN bundle install -j4

# Copy application code
COPY . ./

# Compile assets (now with devDependencies available)
ENV RAILS_LOG_TO_STDOUT true
ENV SHAKAPACKER_NODE_MODULES_BIN_PATH ./node_modules/.bin
RUN SECRET_KEY_BASE=dummy bundle exec rails assets:precompile

# Production stage - minimal runtime image
FROM ruby:3.4.3-slim as production

ENV RAILS_ENV production
WORKDIR /app

# Update rubygems
RUN gem update --system
RUN printf "install: --no-rdoc --no-ri\nupdate:  --no-rdoc --no-ri" > ~/.gemrc
RUN gem install --no-document --force bundler -v 2.4.21

# Install runtime and build dependencies
RUN apt-get update -qq && apt-get install -y --no-install-recommends \
      build-essential \
      postgresql-client \
      libpq-dev \
      libyaml-dev \
      tzdata \
      curl \
      gnupg2 \
      git \
      ca-certificates \
      libvips && \
    rm -rf /var/lib/apt/lists/*

# Set timezone
RUN ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime

# Install Node.js 22.x (runtime only)
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && \
    apt-get update && \
    apt-get install -y --no-install-recommends nodejs && \
    rm -rf /var/lib/apt/lists/*

# Copy gems configuration
COPY Gemfile Gemfile.lock ./
RUN bundle install -j4

# Install only production npm packages
COPY package.json package-lock.json ./
RUN npm install --omit=dev

# Copy application code from builder (excluding large directories)
COPY --from=builder /app/app ./app
COPY --from=builder /app/bin ./bin
COPY --from=builder /app/config ./config
COPY --from=builder /app/db ./db
COPY --from=builder /app/lib ./lib
COPY --from=builder /app/public ./public
COPY --from=builder /app/Rakefile ./Rakefile
COPY --from=builder /app/config.ru ./config.ru

ENV PORT 3000
ENV RAILS_LOG_TO_STDOUT true
EXPOSE 3000

CMD bin/rails server -p $PORT -e $RAILS_ENV
