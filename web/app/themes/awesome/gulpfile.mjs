import gulp from 'gulp';
const { src, dest, watch, parallel, series } = gulp;

import * as sassCompiler from 'sass';
import gulpSass from 'gulp-sass';
import header from 'gulp-header';
import replace from 'gulp-replace';
import plumber from 'gulp-plumber';
import notify from 'gulp-notify';
import autoprefixer from 'gulp-autoprefixer';
import terser from 'gulp-terser';
import dotenv from 'dotenv';

dotenv.config({ path: '../../../../.env' });

const sass = gulpSass(sassCompiler);

// ENV variables
const assetsURL = process.env.ASSETS_URL || '';

// Paths
const paths = {
  scss: './assets/scss/**/*.scss',
  jsOrigin: './assets/js_origin/**/*.js',
  jsDest: './assets/js',
  cssDest: './assets/css'
};

// Check environment (fallback for gulp-mode)
const isLocal = process.env.NODE_ENV === 'local';

// Compile SCSS
const compileSass = () =>
  src(paths.scss)
    /* local環境ではerrorでも監視を停止しない */
    .pipe(isLocal ? plumber({ errorHandler: notify.onError("SCSS エラー: <%= error.message %>") }) : plumber())
    .pipe(header(`$assets_url: '${assetsURL}';\n`))
    .pipe(sass({ outputStyle: 'compressed' }))
    /* 文字コード指定重複回避 */
    .pipe(replace(/\ufeff/ig, ''))
    /* charsetを頭につけ、 */
    .pipe(header('@charset "UTF-8";\n'))
    /* プレフィックスつけ、 */
    .pipe(autoprefixer({ cascade: false }))   
    /* cssフォルダーにポイ */
    .pipe(dest(paths.cssDest));

// Minify JS
const minifyJs = () =>
  src(paths.jsOrigin)
    .pipe(plumber({ errorHandler: notify.onError("JS エラー: <%= error.message %>") }))
    .pipe(terser())
    .pipe(dest(paths.jsDest));

// Watchers
const watchSass = () => watch(paths.scss, { delay: 500 }, compileSass);
const watchJs = () => watch(paths.jsOrigin, { delay: 500 }, minifyJs);

// Tasks
export default parallel(watchSass, watchJs);
export const assetCompile = series(compileSass, minifyJs);
