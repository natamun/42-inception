FROM debian:11

RUN apt-get update && \
    apt-get install -y \
    php7.4-fpm \
    php7.4-mysql \
    wget \
    && rm -rf /var/lib/apt/lists/*

COPY conf/www.conf /etc/php/7.4/fpm/pool.d/www.conf
COPY --chmod=755 tools/wordpress_init.sh /wordpress_init.sh

EXPOSE 9000

ENTRYPOINT ["/wordpress_init.sh"]

CMD ["php-fpm7.4", "-F"]
