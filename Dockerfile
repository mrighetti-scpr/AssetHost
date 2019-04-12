FROM ruby:2.3.4-alpine
MAINTAINER SCPR Developers <scprdev@scpr.org>

ENV HOME /home/assethost
WORKDIR $HOME

ENV PATH="${HOME}/bin:${PATH}"
ENV RAILS_ENV="production"

RUN apk update && apk add --no-cache \
  make \
  gcc \
  libgcc \
  g++ \
  libc-dev \
  libffi-dev \
  imagemagick \
  exiftool \
  git \
  ruby-json \
  yaml \
  zlib-dev \
  libxml2-dev \
  libxslt-dev \
  tzdata \
  yaml-dev \
  nginx \
  openrc \
  python \
  nodejs \
  && addgroup -S assethost && adduser -S -g assethost assethost

COPY Gemfile* $HOME/

RUN gem install bundler \
  && bundle install

ENV BUNDLE_GEMFILE=$HOME/Gemfile \
    BUNDLE_JOBS=2

COPY frontend $HOME/frontend
RUN npm install --prefix ./frontend \
  && npm install -g ember-cli

COPY . .

RUN bundle exec rake resources:precompile \
  && rm -rf frontend/ \
  && rm -rf tmp/* && rm -rf log/* \
  && ln -sf /dev/stdout log/access.log \
  && ln -sf /dev/stderr log/error.log \
  && touch log/development.log \
  && touch log/production.log \
  && ln -sf /dev/stdout log/development.log \
  && ln -sf /dev/stdout log/production.log \
  && chown -R assethost:assethost tmp \
  && chmod -R u+X tmp \
  && chown -R assethost:assethost log \
  && chmod -R u+X tmp \
  && chown -R assethost:assethost db \
  && chmod -R u+X db \
  && cp nginx.conf /etc/nginx/nginx.conf

USER assethost

EXPOSE 2015

CMD server

