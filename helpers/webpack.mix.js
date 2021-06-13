const mix = require('laravel-mix');

mix.js('resources/js/app.js', 'public/js')
    .postCss('resources/css/app.css', 'public/css', [
        require("@tailwindcss/jit"),
        require('postcss-import'),
    ]);

// Local browser sync
if (! mix.inProduction()) {
    mix.browserSync({
        proxy:  "https://"+process.env.APP_BROWSER_SYNC,
        host:   process.env.APP_BROWSER_SYNC,
        open:   'external'
    });
}
