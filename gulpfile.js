var gulp = require('gulp'),
    coffee = require('gulp-coffee'),
    mustache = require('gulp-mustache'),
    download = require('gulp-download'),
    cssMin = require('gulp-cssnano'),
    uglify = require('gulp-uglify'),
    jade = require('gulp-jade'),
    nop = require('gulp-nop'),
    rename = require('gulp-rename'),
    path = require('path'),
    fs = require('fs');

var finalDest = process.env.DESTINATION || "./dest/",
    configuration = require('./configuration.json'),
    files = [
        /* --- HTML */

        /* Main page */
    {
        type: 'jade',
        file: './src/jade/index.jade',
        finalName: 'index.html'
    },
        /* --- JavaScript */
        /* -- Libraries */

        /* Loading bar */
    {
        type: 'js', 
        file: './bower_components/nanobar/nanobar.min.js'
    },
        /* Image lazyloader */
    {
        type: 'js',
        file: './bower_components/lazysizes/lazysizes.min.js'
    },
        /* Markdown parser */
    {
        type: 'js',
        file: './bower_components/marked/marked.min.js'
    },
        /* JavaScript lazyloader */
    {
        type: 'js',
        minify: true,
        file: './bower_components/requirejs/require.js',
        finalName: 'require.min.js'
    },
        /* IndexedDB wrapper */
    {
        type: 'js',
        file: './bower_components/dexie/dist/latest/Dexie.min.js',
    },
        /* Touch gesture support */
    {
        type: 'js',
        file: './bower_components/hammerjs/hammer.min.js',
    },
        /* Emoji library */
    {
        type: 'js',
        file: './bower_components/emojione/lib/js/emojione.min.js'
    },
        /* Promise shim */
    {
        type: 'js',
        file: './bower_components/es6-promise-polyfill/promise.min.js'
    },
        /* -- Own code */

        /* Main page logic */
    {
        type: 'js',
        coffeeCompile: true,
        minify: true,
        file: './src/coffee/main.coffee',
        finalName: 'main.min.js'
    },
        /* RequireJS configuration */
    {
        type: 'js',
        coffeeCompile: true,
        minify: true,
        file: './src/coffee/require-cfg.coffee',
        finalName: 'require-cfg.min.js'
    },
    {
        type: 'js',
        coffeeCompile: true,
        minify: true,
        file: './src/coffee/ga.coffee',
        finalName: 'ga.min.js'
    },
        /* Custom markdown renderer */
    {
        type: 'js',
        coffeeCompile: true,
        minify: true,
        file: './src/coffee/marked-customrenderer.coffee',
        finalName: 'marked-customrenderer.min.js'
    },
        /* Page content cacher */
    {
        type: 'js',
        coffeeCompile: true,
        minify: true,
        file: './src/coffee/cache-worker.coffee',
        finalName: 'cache-worker.min.js'
    },
        /* --- Looks */

        /* Base CSS */
    {
        type: 'css',
        file: `https://bootswatch.com/${configuration.bootstrapTheme}/bootstrap.min.css`
    },
        /* EmojiOne library CSS */
    {
        type: 'css',
        file: './bower_components/emojione/assets/css/emojione.min.css'
    },
        /* Custom CSS */
    {
        type: 'css',
        minify: true,
        file: './src/css/index.css',
        finalName: 'index.min.css'
    },
        /* 'Back to top' button */
    {
        type: 'img',
        file: 'https://raw.githubusercontent.com/encharm/Font-Awesome-SVG-PNG/master/white/svg/arrow-circle-up.svg'
    }
];

gulp.task('default', [], function(){
    files.forEach(function(file){
        var src = (RegExp("http(s)?:").test(file.file))?download(file.file):gulp.src(file.file);
        var name = 'finalName' in file?file.finalName:path.basename(file.file);
        var dest;
        switch(file.type){
            case 'js':
                dest = finalDest+'./static/js/';
                src.pipe(('coffeeCompile' in file && file.coffeeCompile)?coffee({bare: true}):nop())
                   .pipe(('minify' in file && file.minify)?uglify():nop())
                   .pipe(rename(name)).pipe(gulp.dest(dest));
                break;
            case 'css':
                dest = finalDest+'./static/css/';
                src.pipe(('minify' in file && file.minify)?cssMin():nop()).pipe(rename(name)).pipe(gulp.dest(dest));
                break;
            case 'font': /* Just copy them */
                dest = finalDest+'./static/fonts/';
                src.pipe(gulp.dest(dest));
                break;
            case 'img':
                dest = finalDest+'./static/img/';
                src.pipe(gulp.dest(dest));
                break;
            case 'jade':
                dest = finalDest+'./';
                src.pipe(mustache(configuration)).pipe(jade()).pipe(rename(name)).pipe(gulp.dest(dest));
        }
    });
});
