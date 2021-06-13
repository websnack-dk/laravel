#!/bin/bash
# bash script to setup base laravel
#

# replace db config
curl -s https://raw.githubusercontent.com/websnack-dk/laravel/main/helpers/database.php --output  config/database.php  --silent

composer require spatie/laravel-sitemap
composer spatie/laravel-cookie-consent
php artisan vendor:publish --provider="Spatie\CookieConsent\CookieConsentServiceProvider" --tag="cookie-consent-config"

composer require intervention/image
