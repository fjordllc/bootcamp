FROM ruby:3.1.4-slim

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
      rustc \
      cargo

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
RUN gem install logger
RUN bundle config set --local force_ruby_platform true
RUN bundle install -j4

# Compile assets
COPY . ./
RUN gem install logger
RUN bundle config set --local force_ruby_platform true
RUN bundle update --conservative
RUN SECRET_KEY_BASE=dummy RAILS_ENV=production NODE_OPTIONS=--openssl-legacy-provider bundle exec rails assets:precompile

ENV PORT 3000
EXPOSE 3000

CMD bin/rails server -p $PORT -e $RAILS_ENV
