FROM debian:11

RUN apt-get update && \
    apt-get install -y \
    mariadb-server \
    && rm -rf /var/lib/apt/lists/*

COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf
COPY --chmod=755 tools/mariadb_init.sh /mariadb_init.sh

EXPOSE 3306

ENTRYPOINT ["/mariadb_init.sh"]

CMD ["mysqld", "--user=mysql"]
