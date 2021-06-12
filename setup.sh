#!/bin/bash

REST="$(tput sgr0)"
RED="$(tput setaf 1)"
GREEN="$(tput setaf 2)"
YELLOW="$(tput setaf 3)"
BLUE="$(tput setaf 4)"


# Prompt for auto install or exit
function require_program() {
  if ! type "$1" > /dev/null 2>&1; then
    echo "$RED $1 is required. Please install it and try again. $REST"
    exit 1
  fi
}

require_program "ddev"
require_program "mutagen"

