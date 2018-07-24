#!/bin/bash

platform='unknown'
unamestr=`uname`
if [[ "$unamestr" == 'Linux' ]]; then
   platform='linux'
elif [[ "$unamestr" == 'FreeBSD' ]]; then
   platform='freebsd'
fi

#l'applicazione anagrafica
cd _anagrafica
npm install
npm run buildprod
cd ..

#se serve aggiornare l'ambiente php
if [[ "$unamestr" == 'Linux' ]]; then
    cd _server/web/app/
    #phpbrew use 5.6.8
    composer update
    cd ../../../
fi

rm -rf _site

rbenv local 2.4.2

rm -rf vendor/

bundler install --path vendor/bundle
bundle exec jekyll build

rm -rf assets/js/anagrafica/

mkdir -p assets/js/anagrafica/

cp _anagrafica/dist/inline.*.bundle.js assets/js/anagrafica/inline.bundle.js
cp _anagrafica/dist/main.*.bundle.js assets/js/anagrafica/main.bundle.js
cp _anagrafica/dist/polyfills.*.bundle.js assets/js/anagrafica/polyfills.bundle.js
cp _anagrafica/dist/vendor.*.bundle.js assets/js/anagrafica/vendor.bundle.js

cp _anagrafica/dist/styles.*.bundle.css assets/css/anagrafica/styles.bundle.css

if [[ $platform == 'linux' ]]; then
    # linux
    chattr +i _server/web/public/index.php
    rm -rf _server/web/public/*
    chattr -i _server/web/public/index.php
elif [[ $platform == 'freebsd' ]]; then
    # macosx
    chflags uchg _server/web/public/index.php
    rm -rf _server/web/public/*
    chflags nouchg _server/web/public/index.php   
fi

cp -r _site/* _server/web/public/

#docker run --rm --volume=$PWD:/srv/jekyll -it jekyll/builder:3.5.0 jekyll build
#docker run --rm --volume=$PWD:/srv/jekyll -it jekyllbuilder:3.5.0 jekyll build

# per il debug
# docker run --rm --volume=$PWD:/srv/jekyll -it jekyll/builder:3.5.0 /bin/bash

# https://github.com/nanoninja/docker-nginx-php-mysql
# https://hub.docker.com/r/jguyomard/jekyll-builder/
