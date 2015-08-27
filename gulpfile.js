var gulp = require('gulp'),
    coffee = require('gulp-coffee'),
    download = require('gulp-download'),
    cssMin = require('gulp-minify-css'),
    uglify = require('gulp-uglify'),
    jade = require('gulp-jade'),
    nop = require('gulp-nop'),
    rename = require('gulp-rename'),
    path = require('path');

var finalDest = process.env.DESTINATION || "./dest/",
    files = [
    {
        type: 'jade',
        file: './src/jade/index.jade',
        finalName: 'index.html'
    },
    {
        type: 'js', 
        file: './bower_components/nanobar/nanobar.min.js'
    },
    {
        type: 'js',
        file: './bower_components/lazysizes/lazysizes.min.js'
    },
    {
        type: 'js',
        file: './bower_components/marked/marked.min.js'
    },
    {
        type: 'js',
        minify: true,
        file: './bower_components/requirejs/require.js',
        finalName: 'require.min.js'
    },
    {
        type: 'js',
        file: './bower_components/jquery/dist/jquery.min.js'
    },
    {
        type: 'js',
        file: './bower_components/dexie/dist/latest/Dexie.min.js',
    },
    {
        type: 'js',
        coffeeCompile: true,
        minify: true,
        file: './src/coffee/main.coffee',
        finalName: 'main.min.js'
    },
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
        file: './src/coffee/marked-customrenderer.coffee',
        finalName: 'marked-customrenderer.min.js'
    },
    {
        type: 'js',
        coffeeCompile: true,
        minify: true,
        file: './src/coffee/cache-worker.coffee',
        finalName: 'cache-worker.min.js'
    },
    {
        type: 'css',
        file: 'https://bootswatch.com/darkly/bootstrap.min.css'
    },
    {
        type: 'css',
        minify: true,
        file: './src/css/index.css',
        finalName: 'index.min.css'
    },
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
                src.pipe(jade()).pipe(rename(name)).pipe(gulp.dest(dest));
        }
    });
});
