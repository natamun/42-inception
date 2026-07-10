#!/bin/bash

MYSQL_PASSWORD=$(cat /run/secrets/db_password)
WP_ADMIN_PASSWORD=$(cat /run/secrets/wp_admin_password)
WP_USER_PASSWORD=$(cat /run/secrets/wp_user_password)

until echo > /dev/tcp/${MYSQL_HOSTNAME}/3306 2>/dev/null; do
	sleep 1
done

if [ ! -f /var/www/wordpress/wp-login.php ]; then
	wp core download --path=/var/www/wordpress --locale=en_US --allow-root
fi

if [ ! -f /var/www/wordpress/wp-config.php ]; then
	wp config create \
		--dbname=${MYSQL_DATABASE} \
		--dbuser=${MYSQL_USER} \
		--dbpass=${MYSQL_PASSWORD} \
		--dbhost=${MYSQL_HOSTNAME} \
		--path=/var/www/wordpress \
		--allow-root
fi

if ! wp core is-installed --path=/var/www/wordpress --allow-root 2>/dev/null; then
	wp core install \
		--url=${DOMAIN_NAME} \
		--title=${WP_TITLE} \
		--admin_user=${WP_ADMIN_USER} \
		--admin_password=${WP_ADMIN_PASSWORD} \
		--admin_email=${WP_ADMIN_EMAIL} \
		--path=/var/www/wordpress \
		--allow-root

	wp user create \
		${WP_USER} \
		${WP_USER_EMAIL} \
		--role=author \
		--user_pass=${WP_USER_PASSWORD} \
		--path=/var/www/wordpress \
		--allow-root
fi

exec "$@"
