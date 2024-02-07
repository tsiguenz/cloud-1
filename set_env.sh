#!/bin/bash

set -eu

ENV_FILE=srcs/.env
INVENTORY=inventory.yml

function create_env_file() {
	if [ ! -f $ENV_FILE ]; then
		echo "File ${ENV_FILE} does not exist. Creating it..."
	else
		echo "File ${ENV_FILE} exists, do you want to overwrite it? (y/n)"
		read -r OVERWRITE
		if [ "${OVERWRITE}" = "y" ]; then
			echo "Overwriting ${ENV_FILE}..."
			rm -f ${ENV_FILE}
		else
			echo "Not overwriting ${ENV_FILE}"
			exit 0
		fi
	fi
	touch ${ENV_FILE}
}

function set_ansible_host() {
	if grep "ansible_host" $INVENTORY | sed 's/^\s*//g'; then
		echo "Host is already set in $INVENTORY"
		echo "Edit manually if you want to change it."
		return
	fi
	echo "Enter value ansible_host:"
	read -r VALUE
	echo "      ansible_host: $VALUE" >>$INVENTORY
}

function set_env_var() {
	echo "${1}=\"${2}\"" >>${ENV_FILE}
}

function ask_to_set_env_var() {
	echo "Enter value for ${1}:"
	read -r VALUE
	set_env_var "${1}" "${VALUE}"
}

function generate_random_env_var() {
	echo "Generating random value for ${1}..."
	RAND=$(openssl rand -hex 32)
	set_env_var "${1}" "${RAND}"
}

function set_env() {
	set_ansible_host
	create_env_file
	ask_to_set_env_var "DB_NAME"
	ask_to_set_env_var "DB_USER"
	generate_random_env_var "DB_PASSWORD"
	generate_random_env_var "DB_ROOT_PASSWORD"

	ask_to_set_env_var "WP_ADMIN"
	generate_random_env_var "WP_ADMIN_PASSWORD"
	ask_to_set_env_var "WP_ADMIN_MAIL"

	ask_to_set_env_var "WP_USER"
	generate_random_env_var "WP_USER_PASSWORD"
	ask_to_set_env_var "WP_USER_MAIL"

	ask_to_set_env_var "WP_TITLE"
	ask_to_set_env_var "WP_URL"

	generate_random_env_var "WORDPRESS_AUTH_KEY"
	generate_random_env_var "WORDPRESS_SECURE_AUTH_KEY"
	generate_random_env_var "WORDPRESS_LOGGED_IN_KEY"
	generate_random_env_var "WORDPRESS_NONCE_KEY"
	generate_random_env_var "WORDPRESS_AUTH_SALT"
	generate_random_env_var "WORDPRESS_SECURE_AUTH_SALT"
	generate_random_env_var "WORDPRESS_LOGGED_IN_SALT"
	generate_random_env_var "WORDPRESS_NONCE_SALT"
}

set_env
exit 0
