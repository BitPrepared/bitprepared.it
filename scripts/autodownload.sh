#!/bin/bash

cd /tmp

curl -s https://api.github.com/repos/bitprepared/bitprepared.it/releases/latest \
| grep "browser_download_url" \
| cut -d : -f 2,3 \
| tr -d \" \
| wget -qi -

unzip release.zip

rm -rf /var/www/www.bitprepared.it/htdocs/

mv _site/ /var/www/www.bitprepared.it/htdocs/

chown -R wwwbit:wwwbit /var/www/www.bitprepared.it/htdocs/

rm release.zip