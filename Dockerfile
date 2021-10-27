FROM ruby:2.7.4-alpine

ENV RAILS_ENV production
WORKDIR /app

# Update rubygems
RUN gem update --system
RUN printf "install: --no-rdoc --no-ri\nupdate:  --no-rdoc --no-ri" > ~/.gemrc
RUN gem install --no-document --force bundler -v 2.2.24
RUN bundle config set without development:test

# Install packages
RUN apk add --no-cache \
      yarn \
      ruby-dev \
      build-base \
      git \
      nodejs \
      postgresql-dev postgresql \
      tzdata && \
      cp /usr/share/zoneinfo/Asia/Tokyo /etc/localtime

# ImageMagick
RUN apk add --no-cache imagemagick bash pngcrush optipng=0.7.7-r0 ghostscript-fonts

# Install npm packages
COPY package.json yarn.lock ./
RUN yarn install --production --ignore-engines

# Install gems
COPY Gemfile Gemfile.lock ./
RUN CFLAGS="-Wno-cast-function-type" BUNDLE_BUILD__SASSC="--disable-march-tune-native" BUNDLE_FORCE_RUBY_PLATFORM=1 bundle install -j4

# Compile assets
COPY . ./
RUN SECRET_KEY_BASE=dummy bin/rails assets:precompile

ENV PORT 3000
EXPOSE 3000

CMD bin/rails server -p $PORT -e $RAILS_ENV
