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

  # Save base command to setup composer etc.
  mkdir -p .ddev/commands/web/
  curl -s https://raw.githubusercontent.com/websnack-dk/laravel/main/helpers/setup_base_laravel.sh > .ddev/commands/web/setup_base_laravel --silent

  # Setup Redis
  mkdir -p .ddev/redis/
  curl -s https://raw.githubusercontent.com/websnack-dk/laravel/main/docker-compose/redis/redis.conf > .ddev/redis/redis.conf --silent
  curl -s https://raw.githubusercontent.com/websnack-dk/laravel/main/docker-compose/redis/docker-compose.redis.yaml > .ddev/docker-compose.redis.yaml --silent

  ddev start

  # Remove files in web-container
  ddev . --dir /var/www/html rm -rf index.html
  ddev . --dir /var/www/html rm -rf test
  ddev . --dir /var/www/html rm -rf .idea
  ddev . --dir /var/www/html rm -rf public

  # install laravel
  ddev . composer create --prefer-dist laravel/laravel
  ddev . mv laravel/* .
  ddev . mv laravel/.env.example .
  ddev . mv laravel/.gitignore .
  ddev . rm -rf laravel

  ddev . rm -r webpack.mix.js         # Remove std files
  ddev . rm -r resources/css/app.css  # Remove std files
  # ddev . rm -r tailwind.config.js  # Remove std files @todo: Fix later (Check base laravel setup script)

  ddev . "cat .env.example | sed  -E 's/DB_(HOST|DATABASE|USERNAME|PASSWORD)=(.*)/DB_\1=db/g' > .env"
  ddev . "sed -i -e 's/DB_CONNECTION=mysql/DB_CONNECTION=ddev/g' .env"
  ddev . "sed -i -e 's/SESSION_LIFETIME=120/SESSION_LIFETIME=525600/g' .env" #Localhost - 1 year session lifetime
  ddev . "php artisan key:generate"
  message "Laravel config changed" "success"

  # Retrieve base files
  curl -s https://raw.githubusercontent.com/websnack-dk/laravel/main/helpers/ray.php > ray.php                   --create-dirs  --silent
  curl -s https://raw.githubusercontent.com/websnack-dk/laravel/main/helpers/webpack.mix.js > webpack.mix.js     --create-dirs  --silent
  curl -s https://raw.githubusercontent.com/websnack-dk/laravel/main/helpers/app.css > resources/css/app.css     --create-dirs  --silent
  message "Helper files retrieved" "success"

  # Setup mutagen
  message "Setting up mutagen sync script in current ddev project"
  curl https://raw.githubusercontent.com/williamengbjerg/ddev-mutagen/master/setup.sh | bash

  ddev setup_base_laravel
  ddev . composer install
  message "Composer installed" "success"

  ddev . artisan optimize
  message "Env file changed" "success"

  # Remove install setup once finished
  ddev . rm -r .ddev/commands/web/setup_base_laravel

}

setup_ddev
