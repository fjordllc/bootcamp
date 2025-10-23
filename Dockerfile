# Build stage - includes devDependencies for asset compilation
FROM ruby:3.1.6-slim as builder

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

# Install Node.js 22.19.0
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && \
    apt-get update && \
    apt-get install -y --no-install-recommends nodejs=22.19.0-1nodesource1 && \
    apt-mark hold nodejs && \
    rm -rf /var/lib/apt/lists/*

# Install latest yarn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends yarn && \
    rm -rf /var/lib/apt/lists/*

# Set timezone
RUN ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime

# Install ALL npm packages (including devDependencies for asset compilation)
COPY package.json yarn.lock ./
RUN yarn install --ignore-engines

# Install gems
COPY Gemfile Gemfile.lock ./
RUN bundle install -j4

# Copy application code
COPY . ./

# Compile assets (now with devDependencies available)
ENV RAILS_LOG_TO_STDOUT true
RUN SECRET_KEY_BASE=dummy bundle exec rails assets:precompile

# Production stage - minimal runtime image
FROM ruby:3.1.6-slim as production

ENV RAILS_ENV production
WORKDIR /app

# Update rubygems
RUN gem update --system
RUN printf "install: --no-rdoc --no-ri\nupdate:  --no-rdoc --no-ri" > ~/.gemrc
RUN gem install --no-document --force bundler -v 2.4.21

# Install only runtime dependencies
RUN apt-get update -qq && apt-get install -y --no-install-recommends \
      postgresql-client \
      libpq-dev \
      tzdata \
      ca-certificates \
      libvips && \
    rm -rf /var/lib/apt/lists/*

# Set timezone
RUN ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime

# Install Node.js 22.19.0 (runtime only)
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && \
    apt-get update && \
    apt-get install -y --no-install-recommends nodejs=22.19.0-1nodesource1 && \
    apt-mark hold nodejs && \
    rm -rf /var/lib/apt/lists/*

# Install yarn for runtime
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends yarn && \
    rm -rf /var/lib/apt/lists/*

# Copy gems configuration
COPY Gemfile Gemfile.lock ./
RUN bundle install -j4

# Install only production npm packages
COPY package.json yarn.lock ./
RUN yarn install --prod --ignore-engines

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
