var gulp = require('gulp'),
    coffee = require('gulp-coffee'),
    download = require('gulp-download'),
    cssMin = require('gulp-minify-css'),
    debug = require('gulp-debug'),
    closureCompiler = require('gulp-closure-compiler'),
    jade = require('gulp-jade'),
    del = require('del');

var finalDest = "./dest/"

var downloadFiles = [
    {type: 'css', url: 'https://bootswatch.com/darkly/bootstrap.min.css'}
]

var copyFiles = [
    {type: 'js', file: './bower_components/nanobar/nanobar.js'},
    {type: 'js', file: './bower_components/lazysizes/lazysizes.min.js'},
    {type: 'js', file: './bower_components/marked/marked.min.js'},
    {type: 'js', file: './bower_components/requirejs/require.js'},
    {type: 'font', file: './bower_components/font-awesome/fonts/fontawesome-webfont.eot'},
    {type: 'font', file: './bower_components/font-awesome/fonts/fontawesome-webfont.svg'},
    {type: 'font', file: './bower_components/font-awesome/fonts/fontawesome-webfont.ttf'},
    {type: 'font', file: './bower_components/font-awesome/fonts/fontawesome-webfont.woff'},
    {type: 'font', file: './bower_components/font-awesome/fonts/fontawesome-webfont.woff2'}
];

gulp.task('compile', ["minifyjs", "minifycss", "compileindex"]);

gulp.task('coffee', function(){
    return gulp.src('./src/coffee/main.coffee')
        .pipe(coffee({bare: true}))
        .pipe(gulp.dest('./src/compiled', {overwrite: true}))
});

gulp.task('compileindex', function(){
    gulp.src('./src/jade/*.jade')
    .pipe(jade())
    .pipe(debug({title: 'unicorn:'}))
    .pipe(gulp.dest(finalDest+'./'))
});

gulp.task('minifyjs', ["coffee"], function(){
    return gulp.src('./src/compiled/*.*')
        .pipe(closureCompiler({
            compilerPath: '/usr/share/java/closure-compiler/closure-compiler.jar',
            fileName: 'main.min.js',
            compilerFlags: {
                jscomp_off: [ /* FUCK THOSE DAMN WARNINGS */
                    'undefinedVars',
                    'checkVars',
                    'checkTypes',
                    'conformanceViolations',
                    'externsValidation',
                    'fileoverviewTags',
                    'globalThis',
                    'invalidCasts',
                    'misplacedTypeAnnotation',
                    'nonStandardJsDocs',
                    'suspiciousCode',
                    'unknownDefines',
                    'uselessCode',
                ],
//                compilation_level: 'ADVANCED_OPTIMIZATIONS'
            }
         }))
         .pipe(gulp.dest(finalDest+'./static/js/', {overwrite: true}));
});

gulp.task('minifycss', function(){
    gulp.src("./src/css/*.css")
    .pipe(cssMin())
    .pipe(gulp.dest(finalDest+"./static/css"));
    
});

gulp.task('cleantmp', ["copy"], function(cb){
    del([
        './src/compiled'
    ], cb);
});

gulp.task('download', function(){
    downloadFiles.forEach(function(file){
        var dest;
        if(file.type === 'css') {
            dest = './static/css'
        } else if(file.type === 'js') {
            dest = './static/js'
        }
        download(file.url).pipe(gulp.dest(finalDest+dest, {overwrite: true}))
    });
});

gulp.task('copy', ["download", "compile"], function(){
    copyFiles.forEach(function(file){
        var dest;
        if(file.type === 'css') {
            dest = './static/css'
        } else if(file.type === 'js') {
            dest = './static/js'
        } else if(file.type === 'font') {
            dest = './static/fonts'
        }
        gulp.src(file.file).pipe(gulp.dest(finalDest+dest, {overwrite: true}))
    });
});

gulp.task('default', ["cleantmp"]);
