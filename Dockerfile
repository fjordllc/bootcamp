FROM ruby:3.1.6-slim

ENV RAILS_ENV production
WORKDIR /app

# Update rubygems
RUN gem update --system
RUN printf "install: --no-rdoc --no-ri\nupdate:  --no-rdoc --no-ri" > ~/.gemrc
RUN gem install --no-document --force bundler -v 2.4.21

# Install packages
RUN apt-get update -qq && apt-get install -y \
      build-essential \
      git \
      nodejs \
      postgresql-client \
      libpq-dev \
      tzdata \
      curl \
      gnupg2 \
      libyaml-dev

# Install latest yarn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
    apt-get update && apt-get install -y yarn

# Set timezone
RUN ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime

# libvips
RUN apt-get install -y libvips-dev

# Install npm packages
COPY package.json yarn.lock ./
RUN yarn install --prod --ignore-engines

# Install gems
COPY Gemfile Gemfile.lock ./
RUN bundle install -j4

# Copy application code
COPY . ./

# Compile assets
ENV RAILS_LOG_TO_STDOUT true
RUN SECRET_KEY_BASE=dummy NODE_OPTIONS=--openssl-legacy-provider bundle exec rails assets:precompile

ENV PORT 3000
EXPOSE 3000

CMD bin/rails server -p $PORT -e $RAILS_ENV
