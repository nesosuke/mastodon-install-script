#!/bin/bash
#mastodon-update-script 
#wrote by nesosuke

# 
# Run on only your responsibilitity. 
#

# Pull Mastodon 
cd ~/live && git pull 
echo $(git tag -l | grep -v 'rc[0-9]*$' | sort -V | tail -n 5)
read -p "Set Mastodon version updating to > " MASTODON_VERSION
git checkout $MASTODON_VERSION


# Conf values 
SKIP_POST_DEPLOYMENT_MIGRATIONS=true
RAILS_ENV=production


# Update pkg(s) 
sudo apt update -y 
sudo apt upgrade -y 
cd ~/.rbenv/plugins/ruby-build && git pull 
rbenv install $(cat ~/live/.ruby_version)
rbenv global $(cat ~/live/.ruby_version)
cd ~/live
gem update --system
gem install bundler 
bundle install 
yarn install 


# Migrate  
~/live/bin/tootctl cache clear
bundle exec rails assets:clobber 
bundle exec rails db:migrate 
sudo systemctl restart mastodon-*.service 


# Precompile
bundle exec rails assets:precompile 
bundle exec rails db:migrate  


# Restart mastodon-*.service ###
sudo systemctl restart mastodon-*.service nginx


# Clear cache 
~/live/bin/tootctl cache clear


# EOF
