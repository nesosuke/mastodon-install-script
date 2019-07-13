#!/bin/bash
#mastodon-update-script 
#wrote by nesosuke

# 
# Run on only your responsibilitity. 
#

# Pull Mastodon 
cd ~/live && git pull 
echo ""
read -p "Set Mastodon version updating to > " MASTODON_VERSION
git checkout $MASTODON_VERSION


# Conf values 
SKIP_POST_DEPLOYMENT_MIGRATIONS=true
RAILS_ENV=production
RUBY_VERSION=$(cat ~/live/.ruby_version)


# Update pkg(s) 
sudo apt update -y 
sudo apt upgrade -y 
cd ~/.rbenv/plugins/ruby-build && git pull 
rbenv install $RUBY_VERSION
rbenv global $RUBY_VERSION
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
