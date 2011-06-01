#!/bin/bash
#. $HOME/.bashrc
printf "Importing tv shows on " 
date
printf "\n"

export RAILS_ENV=production

cd /home/entretenerse/webapps/entretenerse/crawler

printf "Crawling...\n"
python2.6 workers/tv_shows.py
printf "Importing...\n"
GEM_HOME=$PWD/../gems ruby1.8.7ee import_tv_shows.rb

printf "Finished at "
date
printf "\n"
