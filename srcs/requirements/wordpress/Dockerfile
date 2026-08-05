FROM debian:12

RUN apt-get update && \
    apt-get install -y \
    php8.2-fpm \
    php8.2-mysql \
    wget \
    && rm -rf /var/lib/apt/lists/*

RUN wget -q https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    -O /usr/local/bin/wp && chmod +x /usr/local/bin/wp \
    && mkdir -p /run/php

COPY conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf
COPY --chmod=755 tools/wordpress_init.sh /wordpress_init.sh

EXPOSE 9000

ENTRYPOINT ["/wordpress_init.sh"]

CMD ["php-fpm8.2", "-F"]
