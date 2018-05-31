FROM php:7.2.6-apache
MAINTAINER Xavier Casahuga <casahuga@gmail.com>

COPY apache2.conf /bin/

# CREATE APACHE PUBLIC FOLDER
RUN mkdir -p /var/www/html/dist/
COPY .htaccess /home/site/wwwroot/dist/.htaccess

RUN a2enmod rewrite expires include deflate

# install the PHP extensions we need
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
         libpng-dev \
         libjpeg-dev \
         libpq-dev \
         libmcrypt-dev \
         libldap2-dev \
         libldb-dev \
         libicu-dev \
         libgmp-dev \
         libmagickwand-dev \
         openssh-server \
                 curl \
                 git \
                 mysql-client \
                 nano \
                 sudo \
                 tcptraceroute \
                 vim \
                 wget \
    && chmod 755 /bin/init_container.sh \
    && echo "root:Docker!" | chpasswd \
    && echo "cd /home" >> /etc/bash.bashrc \
    && ln -s /usr/lib/x86_64-linux-gnu/libldap.so /usr/lib/libldap.so \
    && ln -s /usr/lib/x86_64-linux-gnu/liblber.so /usr/lib/liblber.so \
    && ln -s /usr/include/x86_64-linux-gnu/gmp.h /usr/include/gmp.h \
    && rm -rf /var/lib/apt/lists/*

RUN   \
   rm -f /var/log/apache2/* \
   && rmdir /var/lock/apache2 \
   && rmdir /var/run/apache2 \
   && rmdir /var/log/apache2 \
   && chmod 777 /var/log \
   && chmod 777 /var/run \
   && chmod 777 /var/lock \
   && chmod 777 /bin/init_container.sh \
   && cp /bin/apache2.conf /etc/apache2/apache2.conf \
   && rm -rf /var/www/html \
   && rm -rf /var/log/apache2 \
   && mkdir -p /home/LogFiles \
   && ln -s /home/site/wwwroot /var/www/html \
   && ln -s /home/LogFiles /var/log/apache2 \
   && rm /etc/apache2/sites-available/000-default.conf \
   && rm /etc/apache2/sites-enabled/000-default.conf

COPY sshd_config /etc/ssh/

EXPOSE 2222 80

ENV APACHE_RUN_USER www-data
ENV PHP_VERSION 7.2.6

ENV PORT 80
ENV WEBSITES_PORT 80
ENV WEBSITE_ROLE_INSTANCE_ID localRoleInstance
ENV WEBSITE_INSTANCE_ID localInstance
ENV PATH ${PATH}:/home/site/wwwroot/public

WORKDIR /var/www/html