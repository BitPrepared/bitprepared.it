Bitprepared.it
==============

Sito bitprepared con news ed articoli a gestione pubblica






### INSTALLAZIONE
 
dalla radice del progetto lanciare: 

`bundler install --path vendor/bundle` 						(gem install bundler)


per effetturare dei test 

`bundle exec jekyll server -w`



### BUG WORKAROUND

mini_magick non viene correttamente installato? allora : 

`gem install mini_magick`

### DOCKER

`docker run --rm --volume=$PWD:/srv/jekyll -it jekyll/builder:3.5.0 /bin/bash`

poi 

`apk update`
`apk add imagemagick`
`jekyll build`


### PLUGIN UTILIZZATI

 * https://github.com/robwierzbowski/jekyll-picture-tag
 * https://github.com/slashdotdash/jekyll-lunr-js-search
 
#### CON BUNDLE 

ricordarsi di usare il comando 

`bundle exec jekyll build`
