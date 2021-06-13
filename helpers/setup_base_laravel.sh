#!/bin/bash
# bash script to setup base laravel
#

# Remove unused env settings when using ddev
sed -i '' '/DB_HOST=db/d' .env
sed -i '' '/DB_DATABASE=db/d' .env
sed -i '' '/DB_PASSWORD=db/d' .env
sed -i '' '/DB_USERNAME=db/d' .env
sed -i '' '/DB_PORT=3306/d' .env

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

# https://github.com/barryvdh/laravel-ide-helper
composer require --dev barryvdh/laravel-ide-helper
php artisan clear-compiled
php artisan ide-helper:generate


## NPM INSTALLS ##

npm install
npm install -D tailwindcss@latest postcss@latest autoprefixer@latest
npx tailwindcss init --full

npm run dev
