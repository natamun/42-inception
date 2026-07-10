Inception

## check mariadb docker

**Containers tournent ?**
```bash
docker ps
# attendre : srcs-mariadb-1 et srcs-wordpress-1 up
```

**Named volumes créés ?**
```bash
docker volume ls
# attendre : srcs_mariadb_data et srcs_wordpress_data
```

**Données persistées sur le host ?**
```bash
ls ~/data/mariadb
# attendre : dossiers mysql, wordpress, performance_schema...
ls ~/data/wordpress
# attendre : wp-config.php, wp-login.php, wp-content/...
```

**Logs MariaDB propres ?**
```bash
docker logs srcs-mariadb-1
# attendre : "mysqld: ready for connections." à la fin, port 3306
```

**DB wordpress + users MariaDB corrects ?**
```bash
docker exec -it srcs-mariadb-1 mariadb -u root -pnmunariRoot -e "SHOW DATABASES; SELECT User, Host FROM mysql.user;"
# attendre : databases = information_schema, mysql, performance_schema, wordpress
# attendre : users = root@localhost, wp_user@%, wp_user@localhost, mariadb.sys@localhost
```

**wp_user peut se connecter ?**
```bash
docker exec -it srcs-mariadb-1 mariadb -u wp_user -pwordPress wordpress -e "SELECT 1;"
# attendre : 1
```

## check wordpress docker

**Logs WordPress propres ?**
```bash
docker logs srcs-wordpress-1
# attendre : WordPress downloaded, wp-config.php generated, WordPress installed, Created user 2
```

**PHP-FPM tourne en PID 1 ?**
```bash
docker exec -it srcs-wordpress-1 ps aux
# attendre : php-fpm: master process en PID 1, workers pool www
```

**Port 9000 ouvert ?**
```bash
docker exec srcs-wordpress-1 bash -c "echo > /dev/tcp/127.0.0.1/9000 2>/dev/null && echo OK || echo FAIL"
```

**Tables WordPress créées en DB ?**
```bash
docker exec -it srcs-mariadb-1 mariadb -u root -pnmunariRoot wordpress -e "SHOW TABLES;"
# attendre : wp_posts, wp_users, wp_options... (12 tables)
```

**Les deux users WordPress existent ?**
```bash
docker exec -it srcs-mariadb-1 mariadb -u root -pnmunariRoot wordpress -e "SELECT user_login, user_email FROM wp_users;"
# attendre : nmunari (admin) + natamun (author)
```
