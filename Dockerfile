FROM nginx:latest
# Debian GNU/Linux 12 (bookworm) - nginx/1.25.1

LABEL Maintainer="Ben Thai <vietstar.nt@gmail.com>" \
  Description="Nginx 1.25 & PHP-FPM 8 based on debian 12 bookworm"

RUN apt-get update -y
RUN apt-get install -y vim supervisor curl dirmngr unzip gnupg2 ca-certificates wget ufw
RUN apt-get install -y software-properties-common apt-transport-https lsb-release debian-archive-keyring
RUN apt-get install -y php-fpm php-cli php-mysql php-mbstring php-xml php-gd php-xdebug
RUN apt-get install -y php-ctype php-curl php-dom php-exif php-fileinfo php-iconv php-intl
RUN apt-get install -y php-mysqli php-opcache php-phar php-simplexml php-soap php-xml
RUN apt-get install -y php-xmlreader php-zip php-pdo php-xmlwriter php-tokenizer
RUN apt-get install -y nodejs npm

RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
    php composer-setup.php --install-dir=/usr/local/bin --filename=composer

# Configure certs
COPY ./config/certs /etc/nginx/certs

# Configure nginx
COPY ./config/web/nginx/conf.d/*.* /etc/nginx/conf.d/

# Configure php
COPY ./config/web/php/pool.d/www.conf /etc/php/8.2/fpm/pool.d/www.conf
COPY ./config/web/php/php.ini /etc/php/8.2/fpm/php.ini

# Configure supervisord
COPY ./config/web/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Configure demo nginx
COPY ./src /var/www/dev.org/html/public

RUN chmod -R 755 /var/www/dev.org/html

WORKDIR /var/www/dev.org/html

EXPOSE 80 443

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
