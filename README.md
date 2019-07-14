Bitprepared.it
==============

Sito bitprepared con news ed articoli a gestione pubblica


### REQUIREMENTS
 
ruby 2.4.6 , si puo usare: 

`rbenv install 2.4.6`

--> serve ruby-dev installato (qualunque versione)


### INSTALLAZIONE
 
dalla radice del progetto lanciare: 

`gem install bundler`
`bundler install --path vendor/bundle --verbose`


per effetturare dei test 

`bundle exec jekyll server -w`



### BUG WORKAROUND

mini_magick non viene correttamente installato? allora : 

`gem install mini_magick`



### PLUGIN UTILIZZATI

 * https://github.com/robwierzbowski/jekyll-picture-tag
 * https://github.com/slashdotdash/jekyll-lunr-js-search
 
