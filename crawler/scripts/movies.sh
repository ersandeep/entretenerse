#!/bin/bash
#. $HOME/.bashrc
printf "Importing movies on " 
date
printf "\n"

export RAILS_ENV=production

cd /home/entretenerse/webapps/entretenerse/crawler
pwd

printf "Crawling...\n"
python2.6 workers/movies.py
printf "Importing...\n"
GEM_HOME=$PWD/../gems ruby1.8.7ee import_movies.rb

printf "Finished at "
date
printf "\n"
