#!/bin/bash
# bash script to setup base laravel
#

END="$(tput sgr0)"
RED="$(tput setaf 1)"
GREEN="$(tput setaf 2)"
YELLOW="\033[1;33m"

declare -r VERSION="1.0.0"

# Prompt for auto install or exit
require_program() {
  if ! type "$1" > /dev/null 2>&1; then
    echo "${RED} $1 is required. Please install it and try again. ${END}"
    exit 1
  fi
}

message() {

  if [ "$2" == "error" ]; then
    echo "${RED} $1 ${END}"
  elif [ "$2" == "info" ]; then
    echo -e "${YELLOW} $1 \033[0m"
  elif [ "$2" == "success" ]; then
    echo -e "${GREEN} $1 ${END}"
  else
    echo "$1"
  fi

}

logo() {
    # ASCII
    local logo="
      ██╗    ██╗███████╗██████╗ ███████╗███╗   ██╗ █████╗  ██████╗██╗  ██╗
      ██║    ██║██╔════╝██╔══██╗██╔════╝████╗  ██║██╔══██╗██╔════╝██║ ██╔╝
      ██║ █╗ ██║█████╗  ██████╔╝███████╗██╔██╗ ██║███████║██║     █████╔╝
      ██║███╗██║██╔══╝  ██╔══██╗╚════██║██║╚██╗██║██╔══██║██║     ██╔═██╗
      ╚███╔███╔╝███████╗██████╔╝███████║██║ ╚████║██║  ██║╚██████╗██║  ██╗
       ╚══╝╚══╝ ╚══════╝╚═════╝ ╚══════╝╚═╝  ╚═══╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝
    "

    message "$logo
                            Laravel base setup
                                 v$VERSION
                                 " "info"

}

require_program "ddev"
require_program "mutagen"

setup_ddev() {
  logo

  # Setup ddev folder
  ddev config --project-type=laravel --docroot=public --create-docroot
  message ".ddev directory creating" "success"

  # Change config to prevent port conflicts
  sed -i -e 's%router_http_port: "80"%router_http_port: "8080"%g' .ddev/config.yaml
  sed -i -e 's%router_https_port: "443"%router_https_port: "8443"%g' .ddev/config.yaml
  message "Config changed to prevent port conflict" "success"

  # change php version
  message "Change to PHP 8.0" "success"
  sed -i -e 's%php_version: "7.4"%php_version: "8.0"%g' .ddev/config.yaml

  ddev start

  # Remove files in web-container
  ddev . --dir /var/www/html rm -rf index.html
  ddev . --dir /var/www/html rm -rf test

  # install laravel
  ddev . composer create --prefer-dist laravel/laravel .
  message "Laravel files added" "success"

  # Retrieve base files
  curl -s https://raw.githubusercontent.com/websnack-dk/laravel/main/helpers/ray.php > ray.php                   --create-dirs  --silent
  curl -s https://raw.githubusercontent.com/websnack-dk/laravel/main/helpers/webpack.mix.js > webpack.mix.js     --create-dirs  --silent
  curl -s https://raw.githubusercontent.com/websnack-dk/laravel/main/helpers/app.css > resources/css/app.css     --create-dirs  --silent

  # Setup mutagen
  message "Setting up mutagen sync script in current ddev project"
  curl https://raw.githubusercontent.com/williamengbjerg/ddev-mutagen/master/setup.sh | bash

  # Save command to setup composer etc.
  mkdir -p .ddev/commands/web/
  curl -s https://raw.githubusercontent.com/websnack-dk/laravel/main/helpers/setup_base_laravel.sh > .ddev/commands/web/setup_base_laravel --silent

  # Setup Redis
  mkdir -p .ddev/redis/
  curl -s https://raw.githubusercontent.com/websnack-dk/laravel/main/docker-compose/redis/redis.conf > .ddev/redis/redis.conf --silent
  curl -s https://raw.githubusercontent.com/websnack-dk/laravel/main/docker-compose/redis/docker-compose.redis.yaml > .ddev/docker-compose.redis.yaml --silent

  # Install laravel root directory
  rm -rf .DS_Store # ls -la (make sure hidden DS_ files are removed)

  ddev . "cat .env.example | sed  -E 's/DB_(HOST|DATABASE|USERNAME|PASSWORD)=(.*)/DB_\1=db/g' > .env"
  ddev . "sed -i -e 's%DB_CONNECTION=mysql%sDB_CONNECTION=ddev%g' .env"
  ddev . "php artisan key:generate"

  ddev setup_base_laravel
  ddev . composer install

}

setup_ddev
