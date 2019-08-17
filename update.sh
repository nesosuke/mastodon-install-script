#!/bin/bash
## Run on only your responsibilitity.## 

SKIP_POST_DEPLOYMENT_MIGRATIONS=true


# Pull Mastodon 
cd ~/live   
#git pull
git fetch 
git checkout  $(git tag -l | grep -v 'rc[0-9]*$' | sort -V | tail -n 1) 


# Update pkg(s) 
sudo apt update -y 
sudo apt upgrade -y 
cd ~/.rbenv/plugins/ruby-build && git pull 
rbenv install $(cat ~/live/.ruby-version)
rbenv global $(cat ~/live/.ruby-version)
cd ~/live
gem update --system
gem install bundler 
bundle install 
yarn install 


# Migrate  
RAILS_ENV=production bundle exec rails assets:clobber 
RAILS_ENV=production bundle exec rails db:migrate 
RAILS_ENV=production bundle exec rails assets:precompile 
sudo systemctl restart mastodon-*.service
RAILS_ENV=production ~/live/bin/tootctl cache clear
