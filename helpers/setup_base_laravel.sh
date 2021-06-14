#!/bin/bash
# bash script to setup base laravel
#

END="$(tput sgr0)"
GREEN="$(tput setaf 2)"

# Add variable name for browser sync (line 8)
sed -i '' "8 i\\
APP_BROWSER_SYNC=${DDEV_PROJECT}.${DDEV_TLD}" .env

# replace db config
curl -s https://raw.githubusercontent.com/websnack-dk/laravel/main/helpers/database.php --output  config/database.php  --silent

composer require spatie/laravel-ray
composer require spatie/laravel-sitemap
composer require spatie/laravel-cookie-consent
php artisan vendor:publish --provider="Spatie\CookieConsent\CookieConsentServiceProvider" --tag="cookie-consent-config"

composer require intervention/image

composer require laravel/breeze --dev
php artisan breeze:install

# remove standard tailwind after breeze install
rm -r tailwind.config.js
rm -r resources/css/app.css
curl -s https://raw.githubusercontent.com/websnack-dk/laravel/main/helpers/tailwind.config.js > tailwind.config.js  --silent
curl -s https://raw.githubusercontent.com/websnack-dk/laravel/main/helpers/app.css > resources/css/app.css        --silent

# https://github.com/barryvdh/laravel-ide-helper
composer require --dev barryvdh/laravel-ide-helper
php artisan clear-compiled
php artisan ide-helper:generate

php artisan optimize
echo -e "${GREEN} "Composer installed" ${END}"

## NPM INSTALLS ##

npm install
npm install -D tailwindcss@latest postcss@latest autoprefixer@latest
# npx tailwindcss init --full

# @tailwindcss/typography
npm install @tailwindcss/typography
npm install @tailwindcss/forms
npm install @tailwindcss/aspect-ratio


npm run dev
echo -e "${GREEN} "Npm packages installed" ${END}"
