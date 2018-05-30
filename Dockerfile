FROM ruby:2.3.4-alpine
MAINTAINER Ben Titcomb <btitcomb@scpr.org>

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
  mysql-dev \
  ruby-json \
  yaml \
  zlib-dev \
  libxml2-dev \
  libxslt-dev \
  tzdata \
  yaml-dev \
  nginx \
  openrc \
  nodejs

RUN addgroup -S assethost && adduser -S -g assethost assethost 

ENV HOME /home/assethost

WORKDIR $HOME

COPY . .

ENV PATH="${HOME}/bin:${PATH}"

RUN bundle install \
    && bundle exec rake resources:precompile RAILS_ENV=production \
    && cp nginx.conf /etc/nginx/nginx.conf \
    && rm -rf tmp/* && rm -rf log/* \
    && ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log \
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
    && chmod -R u+X db

USER assethost

EXPOSE 8080

CMD server

