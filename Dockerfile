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

RUN bundle install

RUN cp config/templates/secrets.yml.template config/secrets.yml

RUN bundle exec rake assets:precompile RAILS_ENV=production

RUN chown -R assethost:assethost /var/lib/nginx

RUN chown -R assethost:assethost /var/run

RUN mkdir /run/nginx

RUN cp nginx.conf /etc/nginx/nginx.conf

# forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
  && ln -sf /dev/stderr /var/log/nginx/error.log \
  && touch log/development.log \
  && touch log/production.log \
  && ln -sf /dev/stdout log/development.log \
  && ln -sf /dev/stdout log/production.log

RUN chown -R assethost:assethost /home/assethost/tmp

USER assethost

EXPOSE 8080

CMD server

