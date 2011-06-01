#!/bin/bash
#. /etc/profile
#. $HOME/.profile
printf "Executing Entretenerse Crawler on " 
date
printf "\n"

#export RAILS_GEM_VERSION=2.3.2
export RAILS_ENV=production

cd ~/projects/entretenerse/crawler/

export PATH=/usr/local/bin:$PATH

./scripts/movies.sh
./scripts/plays.sh
./scripts/concerts.sh
./scripts/tv_shows.sh


printf "Crawling finished at "
date
printf "\n"
