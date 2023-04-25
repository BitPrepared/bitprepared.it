# Linear-Jekyll-Theme
Fork of Linear Jekyll Theme - more themes available @ http://jekyll.tips

# Requirements

[Jekyll](https://jekyllrb.com/) 

`$ apt-get install ruby-dev bundler`

`$ gem install jekyll bundler jekyll-paginate`

# Utilizzo [jekyllrb.com](https://jekyllrb.com/docs/structure/)

| index.html --> contiene il codice e la struttura della index   
| _includes  
|----------- nav.html --> contiene il codice del menu  
| _layout --> contiene la struttura dei tre tipi di pagine (post, page, default)  
|----------- post.html --> contiene la struttura degli articoli del blog  
|----------- page.html --> contiene la struttura delle pagine (es software ecc..)  
|----------- default.html --> contiene la struttura standard per le pagine del sito  
| _post --> contiene le pagine del blog (con nome yyyy-mm-dd-titolo.md)  
| _page --> contiene le pagine del sito che non sono ne home page ne pagine del blog  
| _site --> contiene il sito generato da jekyll  


# BUILD WITH DOCKER

`docker run --rm -it --mount type=bind,source=${PWD},target=/srv/jekyll --volume="$PWD/vendor/bundle:/usr/local/bundle:Z" -p 127.0.0.1:4000:4000 jekyll/jekyll:3 jekyll serve`

ATTENZIONE jekyll 4 non e' compatibile