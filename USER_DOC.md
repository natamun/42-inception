# USER_DOC - Inception

## Services provided

| Service   | Role                                      | Port         |
|-----------|-------------------------------------------|--------------|
| NGINX     | HTTPS reverse proxy, serves the website   | 443 (public) |
| WordPress | CMS with PHP-FPM                          | 9000 (internal only) |
| MariaDB   | WordPress database                        | 3306 (internal only) |

NGINX is the only entry point. WordPress and MariaDB are not accessible from outside the Docker network.

---

## Start and stop the project

**Start:**
```bash
make all
```
Builds the Docker images and starts all containers in the background.

**Stop (keep data):**
```bash
make clean
```
Stops and removes containers and volumes. Data on the host (`~/data/`) is preserved.

**Full reset (delete everything):**
```bash
make fclean
```
Stops containers, removes images, and deletes all data from `~/data/`.

**Rebuild from scratch:**
```bash
make re
```
Equivalent to `fclean` then `all`.

---

## Access the website

Before accessing the site, make sure `nmunari.42.ch` resolves to your local machine.
Add this line to `/etc/hosts`:
```
127.0.0.1 nmunari.42.ch
```

| URL                                  | Description              |
|--------------------------------------|--------------------------|
| `https://nmunari.42.ch`              | WordPress website        |
| `https://nmunari.42.ch/wp-admin`     | WordPress admin panel    |

The SSL certificate is self-signed. Your browser will show a security warning - click **Advanced** then **Proceed** to continue.

---

## Credentials

All credentials are stored in `secrets/credentials.txt` at the root of the repository.

```
secrets/credentials.txt
```

This file contains login information for:
- WordPress administrator account
- WordPress standard user account
- MariaDB database user
- MariaDB root user

---

## Check that services are running

**All containers up?**
```bash
docker ps
# Expected: srcs-nginx-1, srcs-wordpress-1, srcs-mariadb-1 all Up
```

**Named volumes created?**
```bash
docker volume ls
# Expected: srcs_mariadb_data and srcs_wordpress_data
```

**Data persisted on host?**
```bash
ls ~/data/mariadb
# Expected: mysql/, wordpress/, performance_schema/...
ls ~/data/wordpress
# Expected: wp-config.php, wp-login.php, wp-content/...
```

**NGINX responding?**
```bash
curl -k https://localhost
# Expected: HTML output from WordPress
```

**Logs for each service:**
```bash
docker logs srcs-nginx-1
docker logs srcs-wordpress-1
# Expected: WordPress downloaded, wp-config.php generated, WordPress installed, Created user 2
docker logs srcs-mariadb-1
# Expected: "mysqld: ready for connections." at the end, port 3306
```

**PHP-FPM running as PID 1?**
```bash
docker exec -it srcs-wordpress-1 ps aux
# Expected: php-fpm: master process as PID 1, workers pool www
```

**Port 9000 open?**
```bash
docker exec srcs-wordpress-1 bash -c "echo > /dev/tcp/127.0.0.1/9000 2>/dev/null && echo OK || echo FAIL"
```

**MariaDB - databases and users correct?**
```bash
docker exec -it srcs-mariadb-1 mariadb -u root -p$(cat secrets/db_root_password.txt) \
  -e "SHOW DATABASES; SELECT User, Host FROM mysql.user;"
# Expected databases: information_schema, mysql, performance_schema, wordpress
# Expected users: root@localhost, wp_user@%, wp_user@localhost, mariadb.sys@localhost
```

**WordPress database reachable?**
```bash
docker exec -it srcs-mariadb-1 mariadb -u wp_user -p$(cat secrets/db_password.txt) wordpress -e "SELECT 1;"
# Expected: 1
```

**WordPress tables created?**
```bash
docker exec -it srcs-mariadb-1 mariadb -u root -p$(cat secrets/db_root_password.txt) wordpress \
  -e "SHOW TABLES;"
# Expected: wp_posts, wp_users, wp_options... (12 tables)
```

**Both WordPress users exist?**
```bash
docker exec -it srcs-mariadb-1 mariadb -u root -p$(cat secrets/db_root_password.txt) wordpress \
  -e "SELECT user_login, user_email FROM wp_users;"
# Expected: nmunari (admin) + natamun (author)
```
