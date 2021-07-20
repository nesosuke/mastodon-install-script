#!/bin/bash
## Run on only your responsibilitity.## 

SKIP_POST_DEPLOYMENT_MIGRATIONS=true


# Pull Mastodon 
cd ~/live   
git fetch upstream
git checkout main
git merge upstream/main

# Reget Yarnpkg pubkey
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -

# Update pkg(s) 
sudo apt update -y 
sudo apt upgrade -y 
cd ~/.rbenv/plugins/ruby-build && git pull 
printf N | rbenv install $(cat ~/live/.ruby-version)
rbenv global $(cat ~/live/.ruby-version)
cd ~/live
gem update --system
gem install bundler:1.17.3
bundle install 
sudo yarn install 


# Migrate  
RAILS_ENV=production bundle exec rails assets:clobber 
RAILS_ENV=production bundle exec rails db:migrate 
RAILS_ENV=production bundle exec rails assets:precompile 
sudo systemctl restart mastodon-*.service
RAILS_ENV=production ~/live/bin/tootctl cache clear
