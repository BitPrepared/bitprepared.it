cd _anagrafica
ng build --prod --environment=test
cd ..

cd _server
phpbrew use 5.6.8
composer update
cd ..

rm -rf _site

cp _anagrafica/dist/inline.*.bundle.js assets/js/anagrafica/inline.bundle.js
cp _anagrafica/dist/main.*.bundle.js assets/js/anagrafica/main.bundle.js
cp _anagrafica/dist/polyfills.*.bundle.js assets/js/anagrafica/polyfills.bundle.js
cp _anagrafica/dist/vendor.*.bundle.js assets/js/anagrafica/vendor.bundle.js

cp _anagrafica/dist/styles.*.bundle.css assets/css/anagrafica/styles.bundle.css

#docker run --rm --volume=$PWD:/srv/jekyll -it jekyll/builder:3.5.0 jekyll build
docker run --rm --volume=$PWD:/srv/jekyll -it jekyllbuilder:3.5.0 jekyll build

# per il debug
# docker run --rm --volume=$PWD:/srv/jekyll -it jekyll/builder:3.5.0 /bin/bash

# https://github.com/nanoninja/docker-nginx-php-mysql
# https://hub.docker.com/r/jguyomard/jekyll-builder/
