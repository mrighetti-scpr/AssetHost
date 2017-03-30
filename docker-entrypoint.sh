#!/bin/bash

HOME=/etc/mysql /usr/bin/mysqld_safe > /dev/null 2>&1 &
/etc/init.d/redis-server start
/etc/init.d/elasticsearch start
/bin/bash