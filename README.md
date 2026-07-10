Inception

## check mariadb docker

**Container tourne ?**
```bash
docker ps
```

**Named volume créé ?**
```bash
docker volume ls
# attendre : srcs_mariadb_data
```

**Données persistées sur le host ?**
```bash
ls ~/data/mariadb
# attendre : dossiers mysql, wordpress, performance_schema...
```

**Logs propres ?**
```bash
docker logs srcs-mariadb-1
# attendre : "mysqld: ready for connections." à la fin, port 3306
```

**DB wordpress + users corrects ?**
```bash
docker exec -it srcs-mariadb-1 mariadb -u root -p<root_password> -e "SHOW DATABASES; SELECT User, Host FROM mysql.user;"
# attendre : databases = information_schema, mysql, performance_schema, wordpress
# attendre : users = root@localhost, wp_user@%, wp_user@localhost, mariadb.sys@localhost
```

**wp_user peut se connecter ?**
```bash
docker exec -it srcs-mariadb-1 mariadb -u wp_user -p<wp_password> wordpress -e "SELECT 1;"
# attendre : +---+ | 1 | +---+ | 1 | +---+
```
