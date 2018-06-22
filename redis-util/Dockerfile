FROM redis
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get -y update \
  && apt-get -y upgrade \
  && apt-get -y --no-install-recommends install ruby wget python3.4 python-pip \
  && pip install rdbtools \
  && gem install redis -v 3.3.3 \
  && apt-get -y autoremove \
  && apt-get -y clean

# install redis package for ruby , latest has some bug (https://github.com/antirez/redis/issues/1616) so installed version 3.3.3

# download redis-trib.rb , a redis client for ruby to manage redis cluster
RUN wget http://download.redis.io/redis-stable/src/redis-trib.rb -O /usr/local/bin/redis-trib.rb
RUN chmod 755 /usr/local/bin/redis-trib.rb
#ENTRYPOINT [ "/bin/bash" ]
CMD tail -f /dev/null