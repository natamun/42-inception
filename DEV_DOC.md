# DEV_DOC - Inception

## Prerequisites

- Docker and Docker Compose installed
- `make` installed
- A Linux machine or VM (the project must run on a VM per the subject requirements)

---

## Environment setup from scratch

### 1. Clone the repository

```bash
git clone <repo_url>
cd inception
```

### 2. Create the secrets directory

The `secrets/` folder is gitignored. Create it manually with the required files:

```bash
mkdir secrets
echo "your_db_password"       > secrets/db_password.txt
echo "your_db_root_password"  > secrets/db_root_password.txt
echo "your_wp_admin_password" > secrets/wp_admin_password.txt
echo "your_wp_user_password"  > secrets/wp_user_password.txt
touch secrets/credentials.txt
```

Fill `secrets/credentials.txt` with all credentials so the evaluator can log in.

### 3. Create the .env file

The `.env` file is gitignored. Create it at `srcs/.env`:

```bash
cat > srcs/.env << EOF
DOMAIN_NAME=nmunari.42.ch

# MariaDB
MYSQL_DATABASE=wordpress
MYSQL_USER=wp_user
MYSQL_HOSTNAME=mariadb

# WordPress
WP_TITLE=Inception
WP_ADMIN_USER=nmunari
WP_ADMIN_EMAIL=nmunari@student.42lausanne.ch
WP_USER=natamun
WP_USER_EMAIL=your_email@example.com

# Volumes host path (absolute path required)
DATA_PATH=/home/natamun/data
EOF
```

### 4. Configure the domain name

Add this line to `/etc/hosts` on the machine:
```
127.0.0.1 nmunari.42.ch
```

---

## Build and launch

```bash
make all
```

This command:
1. Creates the data directories `~/data/mariadb` and `~/data/wordpress` on the host
2. Builds the three Docker images (mariadb, wordpress, nginx)
3. Starts all containers in detached mode

---

## Useful commands

**Check running containers:**
```bash
docker ps
```

**View logs:**
```bash
docker logs srcs-mariadb-1
docker logs srcs-wordpress-1
docker logs srcs-nginx-1
```

**Open a shell inside a container:**
```bash
docker exec -it srcs-mariadb-1 bash
docker exec -it srcs-wordpress-1 bash
docker exec -it srcs-nginx-1 bash
```

**Check MariaDB:**
```bash
docker exec -it srcs-mariadb-1 mariadb -u root -p$(cat secrets/db_root_password.txt) -e "SHOW DATABASES;"
docker exec -it srcs-mariadb-1 mariadb -u root -p$(cat secrets/db_root_password.txt) wordpress -e "SHOW TABLES;"
```

**Check WordPress users in DB:**
```bash
docker exec -it srcs-mariadb-1 mariadb -u root -p$(cat secrets/db_root_password.txt) wordpress \
  -e "SELECT user_login, user_email FROM wp_users;"
```

**List Docker volumes:**
```bash
docker volume ls
```

**Stop and clean up:**
```bash
make clean    # stops containers, removes volumes (data on host preserved)
make fclean   # full reset including images and ~/data/
```

---

## Data persistence

All persistent data is stored on the host machine under `~/data/`:

| Path                  | Content                        | Docker volume       |
|-----------------------|--------------------------------|---------------------|
| `~/data/mariadb/`     | MariaDB database files         | `srcs_mariadb_data` |
| `~/data/wordpress/`   | WordPress core files + uploads | `srcs_wordpress_data` |

Docker named volumes are configured with `driver: local` and `driver_opts` pointing to these directories. This means data survives container restarts and `make clean`, but is deleted by `make fclean`.

---

## Project structure

```
inception/
├── Makefile
├── secrets/            # gitignored - create manually
│   ├── credentials.txt
│   ├── db_password.txt
│   ├── db_root_password.txt
│   ├── wp_admin_password.txt
│   └── wp_user_password.txt
└── srcs/
    ├── .env            # gitignored - create manually
    ├── docker-compose.yml
    └── requirements/
        ├── mariadb/
        │   ├── Dockerfile
        │   ├── conf/   # MariaDB config
        │   └── tools/  # init script
        ├── wordpress/
        │   ├── Dockerfile
        │   ├── conf/   # PHP-FPM pool config
        │   └── tools/  # WordPress init script
        └── nginx/
            ├── Dockerfile
            └── conf/   # nginx.conf with TLS
```
