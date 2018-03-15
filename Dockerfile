FROM centos:6.9

RUN yum -y update; yum clean all &&\
    yum -y install epel-release wget redis git wget yum-utils; yum clean all &&\
    yum -y install curl ca-certificates gnupg2 build-essential --no-install-recommends; yum clean all &&\
    wget https://dev.mysql.com/get/mysql57-community-release-el6-11.noarch.rpm &&\
    rpm -ivh mysql57-community-release-el6-11.noarch.rpm &&\
    yum update &&\
    yum-config-manager --disable mysql57-community &&\
    yum-config-manager --enable mysql56-community &&\
    yum -y install mysql-community-server &&\
    service mysqld start &&\
    gpg2 --keyserver hkp://keys.gnupg.net --recv-keys D39DC0E3 &&\
    curl -sSL https://get.rvm.io | bash -s

RUN /bin/bash -l -c ". /etc/profile.d/rvm.sh && rvm install 1.8.6-p383"
RUN /bin/bash -l -c ". /etc/profile.d/rvm.sh && rvm install ruby-2.0.0-p353"

COPY bundler-1.0.23.gem .

RUN /bin/bash -l -c ". /etc/profile.d/rvm.sh && rvm 1.8.6-p383@global do gem uninstall --all rubygems-bundler bundler-unload executable-hooks &&\
    rvm 1.8.6-p383@global do gem install rubygems-update -v 1.4.2 &&\
    rvm 1.8.6-p383@global do update_rubygems &&\
    rvm 1.8.6-p383@global do gem install bundler-1.0.23.gem --no-rdoc --no-ri &&\
    rvm use 1.8.6-p383@haiku --create &&\
    rvm use 2.0.0-p353@haiku_themes --create"