FROM centos:6.9

RUN yum -y update; yum clean all
RUN yum -y install epel-release wget redis git wget yum-utils; yum clean all
RUN yum -y install curl ca-certificates gnupg2 build-essential --no-install-recommends; yum clean all

RUN wget https://dev.mysql.com/get/mysql57-community-release-el6-11.noarch.rpm
RUN rpm -ivh mysql57-community-release-el6-11.noarch.rpm
RUN yum update
RUN yum-config-manager --disable mysql57-community
RUN yum-config-manager --enable mysql56-community
RUN yum -y install mysql-community-server

RUN service mysqld start

RUN gpg2 --keyserver hkp://keys.gnupg.net --recv-keys D39DC0E3

RUN curl -sSL https://get.rvm.io | bash -s
RUN /bin/bash -l -c ". /etc/profile.d/rvm.sh && rvm install 1.8.6-p383"
RUN /bin/bash -l -c ". /etc/profile.d/rvm.sh && rvm install ruby-2.0.0-p353"

COPY . .

RUN /bin/bash -l -c  "rvm 1.8.6-p383@global do gem uninstall --all rubygems-bundler bundler-unload executable-hooks"
RUN /bin/bash -l -c  "rvm 1.8.6-p383@global do gem install rubygems-update -v 1.4.2"
RUN /bin/bash -l -c  "rvm 1.8.6-p383@global do update_rubygems"
RUN /bin/bash -l -c  "rvm 1.8.6-p383@global do gem install bundler-1.0.23.gem --no-rdoc --no-ri"

RUN /bin/bash -l -c  "rvm use 1.8.6-p383@haiku --create"
RUN /bin/bash -l -c  "rvm use 2.0.0-p353@haiku_themes --create"