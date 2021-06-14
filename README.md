<a href="https://github.com/websnack-dk/magento/graphs/commit-activity" target="_blank"><img src="https://img.shields.io/badge/Maintained-Yes-green" alt="Maintained - Yes" /></a>

# Base laravel setup  

Automatic install and set up a laravel project with DDEV-local. 
Installs base composer packages with laravel breeze and other packages that is usually being installed separately.  

### Requirements

- [Docker Desktop](https://docs.docker.com/docker-for-mac/apple-m1/)
- [DDEV-local](https://ddev.readthedocs.io/en/stable/)

--- 

## Usage
Copy/Paste command below and enjoy  ☕
```bashpro shell script
bash <(curl -s https://raw.githubusercontent.com/websnack-dk/laravel/main/setup.sh)
```

--- 

## Base composer packages

- laravel/breeze
- spatie/laravel-ray
- spatie/laravel-sitemap
- spatie/laravel-cookie-consent
- intervention/image

- barryvdh/laravel-ide-helper

Add manually to `composer.json` script area.  
  
```php
# Script ...

    "post-update-cmd": [
        "Illuminate\\Foundation\\ComposerScripts::postUpdate",
        "@php artisan ide-helper:generate",
        "@php artisan ide-helper:meta"
    ]
    
# ... 
```



--- 

## Maintainer

- [Websnack, William](https://websnack.dk)

--- 
