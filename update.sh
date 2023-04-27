#!/bin/bash
## Run on only your responsibilitity.##

sudo echo ""

SKIP_POST_DEPLOYMENT_MIGRATIONS=true
export NODE_OPTIONS="--max-old-space-size=1024"


# Pull Mastodon
cd ~/live
git pull

# Reget Yarnpkg pubkey
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -

# Update pkg(s)
cd ~/.rbenv/plugins/ruby-build && git pull
echo N | rbenv install $(cat ~/live/.ruby-version)
rbenv global $(cat ~/live/.ruby-version)
cd ~/live
gem update --system
gem install bundler
bundle update
bundle install
yarn install


# Migrate
RAILS_ENV=production bundle exec rails assets:clobber
RAILS_ENV=production bundle exec rails db:migrate
RAILS_ENV=production bundle exec rails assets:precompile
sudo systemctl restart mastodon-*.service
RAILS_ENV=production ~/live/bin/tootctl cache clear

# Migrate again
RAILS_ENV=production bundle exec rails db:migrate
sudo systemctl restart mastodon-*.service
