FROM debian:jessie-backports

RUN apt-get update --yes && apt-get upgrade --yes
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \ 
  git \
  curl \
  build-essential\
  libssl-dev\
  ca-certificates\
  mysql-server\
  redis-server\
  elasticsearch

USER root

ENV HOME /root

# MYSQL SETUP
RUN chown root /etc/mysql/my.cnf
RUN sed -i -e"s/^bind-address\s*=\s*127.0.0.1/#bind-address = 0.0.0.0/" /etc/mysql/my.cnf
RUN sed -i -e"s/^#max_connections\s*=\s*100/max_connections = 200/" /etc/mysql/my.cnf
RUN echo "\n[mysqld]\nskip-grant-tables\n" >> /etc/mysql/my.cnf
VOLUME ["/var/lib/mysql", "/var/log/mysql"]

EXPOSE 3306

# REDIS SETUP
RUN echo "daemonize yes\nbind 0.0.0.0" >> /etc/redis/redis-serve.conf

RUN sed 's/^daemonize no/daemonize yes/' -i /etc/redis/redis.conf \
 && sed 's/^bind 127.0.0.1/bind 0.0.0.0/' -i /etc/redis/redis.conf \
 && sed 's/^# unixsocket /unixsocket /' -i /etc/redis/redis.conf \
 && sed 's/^# unixsocketperm 755/unixsocketperm 777/' -i /etc/redis/redis.conf \
 && sed '/^logfile/d' -i /etc/redis/redis.conf

VOLUME ["/var/lib/redis", "/var/log/redis"]

EXPOSE 6379 6380

# ELASTICSEARCH SETUP

RUN sed 's/^#START_DAEMON=true/START_DAEMON=true/' -i /etc/default/elasticsearch

VOLUME ["/opt/elasticsearch/data", "/opt/elasticsearch/logs"]

EXPOSE 9200 9300

ADD docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod 777 /usr/local/bin/docker-entrypoint.sh
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

