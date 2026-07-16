*This project has been created as part of the 42 curriculum by nmunari.*

# Inception

## Description

Inception is a system administration project from the 42 curriculum. The goal is to set up a small infrastructure composed of multiple services running in Docker containers, orchestrated with Docker Compose.

The infrastructure includes:
- **NGINX** - HTTPS reverse proxy, the only entry point (port 443, TLSv1.2/TLSv1.3)
- **WordPress + PHP-FPM** - Content Management System, served via FastCGI
- **MariaDB** - Relational database storing WordPress data

All services run in dedicated containers built from Debian 11. Persistent data is stored in Docker named volumes. Sensitive credentials are managed with Docker secrets.

```
  [ Browser ]
       │
       │ HTTPS :443
       ▼
┌─────────────────────────────────────────────────────────────────┐
│  HOST MACHINE                                                   │
│                                                                 │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │  inception_network (bridge)                               │  │
│  │                                                           │  │
│  │  ┌─────────────────┐  FastCGI   ┌─────────────────┐       │  │
│  │  │      nginx      │──────────> │    wordpress    │       │  │
│  │  │      :443       │            │    php-fpm      │       │  │
│  │  └─────────────────┘            │      :9000      │       │  │
│  │           │                     └─────────────────┘       │  │
│  │           │                              │ SQL            │  │
│  │           │                              ▼                │  │
│  │           │                     ┌─────────────────┐       │  │
│  │           │                     │     mariadb     │       │  │
│  │           │                     │      :3306      │       │  │
│  │           │                     └─────────────────┘       │  │
│  └───────────│──────────────────────────────│────────────────┘  │
│              │                              │                   │
│       wordpress_data                  mariadb_data              │
│    (nginx + wordpress)                (mariadb only)            │
│     ~/data/wordpress                  ~/data/mariadb            │
└─────────────────────────────────────────────────────────────────┘
```

### Design choices

**Virtual Machines vs Docker**

A Virtual Machine emulates an entire operating system with its own kernel, hardware abstraction, and full OS stack. It provides strong isolation but is heavy in terms of resources and startup time.

Docker containers share the host kernel and only isolate the userspace (filesystem, processes, network). They are lightweight, start in seconds, and are designed to run a single process per container. For this project, Docker is ideal because each service (NGINX, WordPress, MariaDB) is isolated in its own container without the overhead of a full VM.

**Secrets vs Environment Variables**

Environment variables are visible to any process in the container and can be exposed through inspection (`docker inspect`) or logged accidentally. They are appropriate for non-sensitive configuration (domain name, database name, usernames).

Docker secrets are mounted as files in `/run/secrets/` inside the container, accessible only to the container that declares them, and never stored in the image layers. They are the correct tool for sensitive values (passwords, API keys). In this project, all passwords are managed as secrets.

**Docker Network vs Host Network**

With `network: host`, the container shares the host's network stack - no isolation, all ports are directly exposed. This is a security risk and is forbidden by the subject.

A Docker bridge network (`driver: bridge`) creates an isolated virtual network. Containers can communicate with each other by service name (DNS resolution), but are not reachable from outside unless a port is explicitly published. In this project, only NGINX publishes port 443; MariaDB and WordPress are only accessible within the internal network.

**Docker Volumes vs Bind Mounts**

A bind mount directly maps a host directory into a container (`/home/user/data:/var/lib/mysql`). It is simple but couples the container to the host's filesystem layout, and is forbidden by the subject.

A Docker named volume is managed by Docker. In this project, named volumes are configured with `driver: local` and `driver_opts` to store data at a specific host path (`/home/nmunari/data/`), combining the benefits of named volumes (Docker-managed, portable) with an explicit host location.

---

## Instructions

### Prerequisites

- Docker and Docker Compose
- `make`
- A Linux machine or VM

### Setup

1. **Create the secrets directory** (gitignored - must be created manually):

```bash
mkdir secrets
echo "your_db_password"       > secrets/db_password.txt
echo "your_db_root_password"  > secrets/db_root_password.txt
echo "your_wp_admin_password" > secrets/wp_admin_password.txt
echo "your_wp_user_password"  > secrets/wp_user_password.txt
```

2. **Create `srcs/.env`** (gitignored - must be created manually):

```bash
DOMAIN_NAME=nmunari.42.ch

MYSQL_DATABASE=wordpress
MYSQL_USER=wp_user
MYSQL_HOSTNAME=mariadb

WP_TITLE=Inception
WP_ADMIN_USER=nmunari
WP_ADMIN_EMAIL=nmunari@student.42lausanne.ch
WP_USER=natamun
WP_USER_EMAIL=your@email.com

DATA_PATH=/home/nmunari/data
```

3. **Configure `/etc/hosts`**:

```
127.0.0.1 nmunari.42.ch
```

### Build and run

```bash
make all      # build images and start containers
make clean    # stop containers (data preserved)
make fclean   # full reset including data
make re       # fclean + all
```

### Access

| URL | Description |
|-----|-------------|
| `https://nmunari.42.ch` | WordPress website |
| `https://nmunari.42.ch/wp-admin` | Admin panel |

The SSL certificate is self-signed - accept the browser warning to proceed.

Credentials are listed in `secrets/credentials.txt`.

For detailed usage and developer documentation, see [USER_DOC.md](USER_DOC.md) and [DEV_DOC.md](DEV_DOC.md).

---

## Resources

- [Docker documentation](https://docs.docker.com/)
- [Docker Compose reference](https://docs.docker.com/compose/compose-file/)
- [NGINX documentation](https://nginx.org/en/docs/)
- [PHP-FPM configuration](https://www.php.net/manual/en/install.fpm.configuration.php)
- [WP-CLI documentation](https://wp-cli.org/)
- [MariaDB documentation](https://mariadb.com/kb/en/documentation/)

### AI usage

This project was developed with the assistance of AI to enhance learning and code quality. AI was used for:

**Concept Explanation:** Acting as a virtual tutor to clarify Docker concepts such as named volumes, bridge networks, Docker secrets, PID 1 behavior, and the FastCGI protocol between NGINX and PHP-FPM.

**Documentation:** Writing the English content of this README, USER_DOC.md, and DEV_DOC.md based on structure and directives provided in French.
