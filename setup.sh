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
  ddev config --project-type=laravel --docroot=public --create-docroot
  message ".ddev directory creating" "success"

  # Change config to prevent port conflicts
  message "Change config to prevent port conflict"
  sed -i -e 's%router_http_port: "80"%router_http_port: "8080"%g' .ddev/config.yaml
  sed -i -e 's%router_https_port: "443"%router_https_port: "8443"%g' .ddev/config.yaml

  # change php version
  message "Change to PHP 8.0"
  sed -i -e 's%php_version: "7.4"%php_version: "8.0"%g' .ddev/config.yaml

  # Save command to setup composer etc.
  curl -s https://raw.githubusercontent.com/websnack-dk/laravel/main/helpers/setup_base_laravel.sh > .ddev/commands/web/setup_base_laravel  --create-dirs  --silent

  # Install laravel root directory
  rm -rf .DS_Store --glob # ls -la (make sure hidden DS_ files are removed)
  ddev . composer create --prefer-dist laravel/laravel .
  ddev . "cat .env.example | sed  -E 's/DB_(HOST|DATABASE|USERNAME|PASSWORD)=(.*)/DB_\1=db/g' > .env"
  ddev . "sed -i -e 's%DB_CONNECTION=mysql%sDB_CONNECTION=ddev%g' .env"
  ddev . "php artisan key:generate"

  # Retrieve base files
  curl -s https://raw.githubusercontent.com/websnack-dk/laravel/main/helpers/ray.php > ray.php                   --create-dirs  --silent
  curl -s https://raw.githubusercontent.com/websnack-dk/laravel/main/helpers/webpack.mix.js > webpack.mix.js     --create-dirs  --silent
  curl -s https://raw.githubusercontent.com/websnack-dk/laravel/main/helpers/app.css > resources/css/app.css     --create-dirs  --silent

  # Setup mutagen
  message "Setting up mutagen sync script in current ddev project"
  curl https://raw.githubusercontent.com/williamengbjerg/ddev-mutagen/master/setup.sh | bash

  ddev start
  ddev setup_base_laravel
  ddev . composer install

}

setup_ddev

ddev describe
