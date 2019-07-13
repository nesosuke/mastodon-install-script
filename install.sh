#!/bin/bash

## Input server domain
read -p "Input your server domain w/o \"http\"; e.g. example.com" INSTANCE


## Prepare
sudo adduser mastodon 
sudo adduser mastodon sudo 
sudo apt install -y screen

install_mastodon()
{

## Install Ruby and gem
rm -rf ~/.rbenv
git clone https://github.com/rbenv/rbenv.git ~/.rbenv
git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
cd ~/.rbenv && src/configure && make -C src
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(rbenv init -)"' >> ~/.bashrc
source ~/.bashrc
screen -S install_ruby_263 -d -m rbenv install 2.6.3 


## Install packages
sudo apt update
sudo apt upgrade
sudo apt install -fy git vim curl npm \
  imagemagick ffmpeg libpq-dev libxml2-dev libxslt1-dev file git-core \
  g++ libprotobuf-dev protobuf-compiler pkg-config nodejs gcc autoconf \
  bison build-essential libssl-dev libyaml-dev libreadline6-dev \
  zlib1g-dev libncurses5-dev libffi-dev libgdbm-dev \
  nginx redis-server redis-tools postgresql postgresql-contrib \
  libidn11-dev libicu-dev libjemalloc-dev nginx \
# (c.f. https://qiita.com/yakumo/items/10edeca3742689bf073e about not needing to install "libgdbm5")


## Install yarn
sudo npm install -g yarn 
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
yarn -v


## Setup PostgreSQL
echo "CREATE USER mastodon CREATEDB" | sudo -u postgres psql -f -


## Setup Mastodon 
git clone https://github.com/tootsuite/mastodon.git ~/live
cd ~/live
git checkout $(git tag -l | grep -v 'rc[0-9]*$' | sort -V | tail -n 1)
rbenv global 2.6.3 
gem install bundler --no-ri --no-rdoc
gem install bundler
bundle install \
  -j$(getconf _NPROCESSORS_ONLN) \
  --deployment --without development test
yarn install --pure-lockfile --network-timeout 100000
read -p "Press ENTER to run mastodon:setup"
RAILS_ENV=production bundle exec rake mastodon:setup


## Set up nginx
cp ~/live/dist/nginx.conf ~/live/dist/nginx.conf.original
sed -i ~/live/dist/nginx.conf -e "s/example.com/$INSTANCE/g"
sed -i ~/live/dist/nginx.conf -e 's/# ssl_certificate/ssl_certificate/g'
sudo cp ~/live/dist/nginx.conf /etc/nginx/conf.d/$INSTANCE.conf
sudo vim /etc/nginx/conf.d/$INSTANCE.conf
sudo systemctl restart nginx


## Set up systemd services
sudo cp /home/mastodon/live/dist/mastodon-*.service /etc/systemd/system/
sudo systemctl start mastodon-web mastodon-sidekiq mastodon-streaming
sudo systemctl enable mastodon-web.service mastodon-streaming.service mastodon-sidekiq.service

}

sudo -u mastodon install_mastodon

