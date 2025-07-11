import gulp from 'gulp';
import fs from 'fs';
import path from 'path';
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
import rev from 'gulp-rev';
import revDistClean from 'gulp-rev-dist-clean'

dotenv.config({ path: '../../../../.env' });

const sass = gulpSass(sassCompiler);

// ENV variables
const assetsURL = process.env.ASSETS_URL || '';

// Paths
const paths = {
  scss: './assets/scss/**/*.scss',
  jsOrigin: './assets/js_origin/**/*.js',
  build: './assets/build',
  manifest: './assets/build/rev-manifest.json',
};

// Check environment (fallback for gulp-mode)
const isLocal = process.env.NODE_ENV === 'local';

let manifestData = {};
const collectManifest = (type) => {
  return rev.manifest().on('data', (file) => {
    const json = JSON.parse(file.contents.toString());
    Object.keys(json).forEach((key) => {
      const value = json[key];
      manifestData[`${type}/${key}`] = `${type}/${value}`;
    });
  });
};

const withErrorHandler = (type) =>
  plumber({ errorHandler: notify.onError(`${type} エラー: <%= error.message %>`) });

// Compile SCSS
const compileSass = () =>
  src(paths.scss)
    /* local環境ではerrorでも監視を停止しない */
    .pipe(isLocal ? withErrorHandler('SCSS') : plumber())
    .pipe(header(`$assets_url: '${assetsURL}';\n`))
    .pipe(sass({ outputStyle: 'compressed' }))
    /* 文字コード指定重複回避 */
    .pipe(replace(/\ufeff/ig, ''))
    /* charsetを頭につけ、 */
    .pipe(header('@charset "UTF-8";\n'))
    /* プレフィックスつけ、 */
    .pipe(autoprefixer({ cascade: false }))   
    .pipe(rev())
    /* cssフォルダーにポイ */
    .pipe(dest(`${paths.build}/css`))
    .pipe(collectManifest('css'));

// Minify JS
const minifyJs = () =>
  src(paths.jsOrigin)
    .pipe(withErrorHandler('JS'))
    .pipe(terser())
    .pipe(rev())   
    .pipe(dest(`${paths.build}/js`))
    .pipe(collectManifest('js'));

// Merge manifest data
const writeManifest = (callback) => {
  fs.writeFileSync(paths.manifest, JSON.stringify(manifestData, null, 2));
  callback();
};

// Clean up old files in build directory
async function deleteEmptyDirs(dir) {
  try {
    const files = await fs.promises.readdir(dir);
    await Promise.all(files.map(async (file) => {
      const fullPath = path.join(dir, file);
      const stat = await fs.promises.stat(fullPath);
      if (stat.isDirectory()) {
        await deleteEmptyDirs(fullPath);
      }
    }));
    const remaining = await fs.promises.readdir(dir);
    if (remaining.length === 0) {
      await fs.promises.rmdir(dir); 
    }
  } catch (err) {
    if (err.code !== 'ENOENT') throw err;
  }
}

const cleanOldBuild = () => {
  return new Promise((resolve, reject) => {
    const stream = src(`${paths.build}/**/*`, { read: false })
      .pipe(revDistClean(paths.manifest))
      .on('error', reject)
      .on('finish', async () => {
        try {
          setTimeout(async () => {
            await deleteEmptyDirs(paths.build);
            resolve();
          }, 100); 
        } catch (err) {
          reject(err);
        }
      });
  });
};


// Watchers
const watchSass = () => watch(paths.scss, { delay: 500 }, compileSass);
const watchJs = () => watch(paths.jsOrigin, { delay: 500 }, minifyJs);

// Tasks
export default parallel(watchSass, watchJs);
export const assetCompile = series(parallel(compileSass, minifyJs), writeManifest, cleanOldBuild);
