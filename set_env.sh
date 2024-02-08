#!/bin/bash

set -u

GREEN="\e[32m"
RED="\e[31m"
LIGHT_RED="\e[91m"
DEFAULT="\e[0m"
ENV_FILE=srcs/.env
INVENTORY=inventory.yml
ANSIBLE_HOST_VAR_NAME=ansible_host

function print_info() {
	echo -e "$GREEN""[INFO]: ""$1""$DEFAULT"
}

function print_warning() {
	echo -e "$LIGHT_RED""[WARN]: ""$1""$DEFAULT"
}

function print_error() {
	echo -e "$RED""[ERROR]: ""$1""$DEFAULT"
}

function create_env_file() {
	if [ ! -f $ENV_FILE ]; then
		print_info "File ${ENV_FILE} does not exist. Creating it..."
	else
		echo "File ${ENV_FILE} exists, do you want to overwrite it? (y/n)"
		read -r OVERWRITE
		if [ "${OVERWRITE}" = "y" ]; then
			print_info "Overwriting ${ENV_FILE}..."
			rm -f ${ENV_FILE}
		else
			print_info "Not overwriting ${ENV_FILE}"
			exit 0
		fi
	fi
	touch ${ENV_FILE}
}

function set_ansible_host() {
	if grep $ANSIBLE_HOST_VAR_NAME $INVENTORY > /dev/null; then
		print_info "Host is already set in $INVENTORY"
		print_info "Edit manually if you want to change it."
		return
	fi
	echo "Enter value $ANSIBLE_HOST_VAR_NAME:"
	read -r VALUE
	echo "      $ANSIBLE_HOST_VAR_NAME: $VALUE" >> $INVENTORY
}

function set_wp_url() {
	local ANSIBLE_HOST_LINE
	ANSIBLE_HOST_LINE=$(grep $ANSIBLE_HOST_VAR_NAME $INVENTORY)
	if [ $? -ne 0 ]; then
		print_warning "Can't set WP_URL, $ANSIBLE_HOST_VAR_NAME not set in $INVENTORY..."
		return
	fi
	local HOST=$(echo $ANSIBLE_HOST_LINE \
				| sed "s/^\s*$ANSIBLE_HOST_VAR_NAME: //g")
	set_env_var "WP_URL" "https://$HOST/"

}

function set_env_var() {
	echo "${1}=\"${2}\"" >> ${ENV_FILE}
	print_info "${1}=\"${2}\" added to $ENV_FILE"
}

function ask_to_set_env_var() {
	echo "Enter value for ${1}:"
	read -r VALUE
	set_env_var "${1}" "${VALUE}"
}

function generate_random_env_var() {
	print_info "Generating random value for ${1}..."
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
	set_wp_url

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
