FROM centos:6.9

RUN yum -y update; yum clean all &&\
    yum -y install epel-release wget git wget yum-utils; yum clean all &&\
    yum -y install curl ca-certificates gnupg2 build-essential; yum clean all &&\
    yum -y install zlib-devel libxml2-devel libxslt libxslt-devel unzip sudo gpg

# We require an older version of gcc, newer gcc causes bugs in ruby-1.8.6
RUN yum -y install texinfo gcc; yum clean all
RUN mkdir -p /usr/src && cd /usr/src && wget -q http://www.netgull.com/gcc/releases/gcc-4.1.2/gcc-4.1.2.tar.gz && tar -xzf gcc-4.1.2.tar.gz
RUN cd /usr/src/gcc-4.1.2 && ./configure --prefix=/opt/gcc412 --program-suffix=412 --enable-shared --enable-threads=posix --enable-checking=release --with-system-zlib --disable-libunwind-exceptions --disable-multilib --enable-__cxa_atexit &&\
    sed -i 's/^MAKEINFO.*/MAKEINFO = makeinfo/g' Makefile && make && make install

# Install mysql 5.6 which matches production
RUN wget https://dev.mysql.com/get/mysql57-community-release-el6-11.noarch.rpm
RUN rpm -ivh mysql57-community-release-el6-11.noarch.rpm
RUN yum update &&\
    yum-config-manager --disable mysql57-community &&\
    yum-config-manager --enable mysql56-community &&\
    yum -y install mysql-community-server mysql-community-devel mysql-community-libs

RUN sed -i 's/^sql_mode=.*/sql_mode=NO_ENGINE_SUBSTITUTION/g' /etc/my.cnf

# Setup redis v1.3
COPY redis13 ./redis13
RUN cd redis13 && tar -xzf redis-v1.3.10.tar.gz && cd antirez-redis-92c7466 && make && cp redis-benchmark redis-cli redis-server /usr/bin/ && cp redis.conf /etc/
RUN cp redis13/redis13.conf /etc/ && cp redis13/redis13.sh /etc/init.d/redis13 && chmod 750 /etc/init.d/redis13 && mkdir -p /var/redis/redis13

# Setup redis v2.6
COPY redis2 ./redis2
RUN cd redis2 && tar -xzf redis-2.6.16.tar.gz && cd redis-2.6.16 && make &&\
    cp src/redis-benchmark /usr/bin/redis2-benchmark &&\
    cp src/redis-cli /usr/bin/redis2-cli &&\
    cp src/redis-server /usr/bin/redis2-server
RUN cp /redis2/redis2.conf /etc/ && cp /redis2/redis2.sh /etc/init.d/redis2 && chmod 750 /etc/init.d/redis2 && mkdir -p /var/redis/apiredis2

# Get keys needed to verify rvm install
RUN gpg2 --keyserver hkp://keys.gnupg.net --recv-keys D39DC0E3 &&\
    curl -sSL https://get.rvm.io | bash -s

RUN /bin/bash -l -c ". /etc/profile.d/rvm.sh && rvm install 1.8.6-p383 --disable-binary --with-gcc=/opt/gcc412/bin/gcc412"
RUN /bin/bash -l -c ". /etc/profile.d/rvm.sh && rvm install ruby-2.0.0-p353"

COPY bundler-1.0.23.gem .

RUN /bin/bash -l -c ". /etc/profile.d/rvm.sh && rvm 1.8.6-p383@global do gem uninstall --all rubygems-bundler bundler-unload executable-hooks &&\
    rvm 1.8.6-p383@global do gem install rubygems-update -v 1.4.2 &&\
    rvm 1.8.6-p383@global do update_rubygems &&\
    rvm 1.8.6-p383@global do gem install bundler-1.0.23.gem --no-rdoc --no-ri &&\
    rvm use 1.8.6-p383@haiku --create &&\
    rvm use 2.0.0-p353@haiku_themes --create"

COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod 755 /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["/bin/bash"]
