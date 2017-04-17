FROM ruby:2.3.4-alpine
MAINTAINER Ben Titcomb <btitcomb@scpr.org>

RUN apk update && apk add make gcc libgcc g++ libc-dev libffi-dev imagemagick exiftool git mysql-dev ruby-json yaml zlib-dev libxml2-dev libxslt-dev tzdata yaml-dev

USER root
ENV HOME /root

WORKDIR $HOME

COPY . .

RUN cp config/templates/secrets.yml.template config/secrets.yml

RUN bundle install

CMD ["rails", "s"]

