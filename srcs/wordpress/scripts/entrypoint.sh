#!/bin/bash

sed -i '$ d' /usr/local/bin/docker-entrypoint.sh # we don't want to launch original command

docker-entrypoint.sh php-fpm

function check_env {
    if [ -z "$1" ]; then
        echo "Error: $2 is not set"
        exit 1
    fi
}

CONFIGURED_FILE=/var/www/html/.configure

if [[ ! -f $CONFIGURED_FILE ]]; then
    echo "Configuring wordpress"
    check_env "$WP_URL" "WP_URL"
    check_env "$WP_TITLE" "WP_TITLE"
    check_env "$WP_ADMIN" "WP_ADMIN"
    check_env "$WP_ADMIN_PASSWORD" "WP_ADMIN_PASSWORD"
    check_env "$WP_ADMIN_MAIL" "WP_ADMIN_MAIL"
    check_env "$WP_USER" "WP_USER"
    check_env "$WP_USER_PASSWORD" "WP_USER_PASSWORD"
    check_env "$WP_USER_MAIL" "WP_USER_MAIL"

    wp-cli core install --allow-root --url=$WP_URL --title=$WP_TITLE --admin_user=$WP_ADMIN --admin_password=$WP_ADMIN_PASSWORD --admin_email=$WP_ADMIN_MAIL
    wp-cli user create --allow-root $WP_USER $WP_USER_MAIL --role=author --user_pass=$WP_USER_PASSWORD

    touch $CONFIGURED_FILE
else
    echo "Wordpress already configured, skipping configuration"
fi

php-fpm