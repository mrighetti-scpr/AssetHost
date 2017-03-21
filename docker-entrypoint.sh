#!/bin/bash

/etc/init.d/mysql start
/etc/init.d/redis-server start
/etc/init.d/elasticsearch start
/bin/bash