#!/bin/sh
#This script is only for RasPi (ARMv6). In case of me, I executed on `RasPi zero w` and `Raspbian Stretch based on Debian 9.6`.
#These steps below were executed on 8th Dec 2018; latest versions of Mastodon was "v2.6.5", of Ruby was "2.5.3", of yarn was "1.12.3".
#Official Installaton Documentation; https://docs.joinmastodon.org/administration/installation/#install-fail2ban-so-it-blocks-repeated-login-attempts)

# Set Your Instance Name
export INSTANCE=YOURINSTANCEDOMAIN


# Install curl
sudo apt update
sudo apt upgrade
sudo apt install git vim curl
	# Install more pkgs, if you need
	# `sudo apt install 

# Extend swapfile
sudo vim /etc/dphys-swapfile
	# "CONF_SWAPSIZE": 100-->2048

# Create user "mastodon"
sudo adduser mastodon
sudo adduser mastodon sudo 
su - mastodon

# If error occured, check the latest version at https://nodejs.org/dist/latest-v8.x/
wget https://nodejs.org/dist/latest-v8.x/node-v8.14.0-linux-armv6l.tar.gz
tar -zxvf node-v8.14.0-linux-armv6l.tar.gz
sudo cp -R node-v8.14.0-linux-armv6l/* /usr/local/

# If the versions are printed, installation of node & npm has been succeeded.
node -v
npm -v

### Notice: Above steps are almost the same as the official documentation. 

# Install yarn
sudo npm install yarn 
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
yarn -v

# Install necessary packages 
#(c.f. https://qiita.com/yakumo/items/10edeca3742689bf073e about not needing to install "libgdbm5")
sudo apt update
sudo apt install -y \
  imagemagick ffmpeg libpq-dev libxml2-dev libxslt1-dev file git-core \
  g++ libprotobuf-dev protobuf-compiler pkg-config nodejs gcc autoconf \
  bison build-essential libssl-dev libyaml-dev libreadline6-dev \
  zlib1g-dev libncurses5-dev libffi-dev libgdbm-dev \
  nginx redis-server redis-tools postgresql postgresql-contrib \
  letsencrypt libidn11-dev libicu-dev libjemalloc-dev

# Install rbenv and rbenv-build 
# `rbenv install` will take a lot of time. Drink some tea.
git clone https://github.com/rbenv/rbenv.git ~/.rbenv
cd ~/.rbenv && src/configure && make -C src
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(rbenv init -)"' >> ~/.bashrc
exec bash
git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
rbenv install 2.5.3 
rbenv global 2.5.3

# Install bundler 
gem install bundler --no-ri --no-rdoc

# Setting up PostgreSQL
sudo -u postgres psql
	# in PostgreSQL prompt,execute
	# ```
	# CREATE USER mastodon CREATEDB;
	# \q
	# ``` 


# Download Mastodon from github 
cd && git clone https://github.com/tootsuite/mastodon.git live
cd live
git checkout $(git tag -l | grep -v 'rc[0-9]*$' | sort -V | tail -n 1)

# Install the dependencies
bundle install \
  -j$(getconf _NPROCESSORS_ONLN) \
  --deployment --without development test
yarn install --pure-lockfile --network-timeout 100000

# Set up nginx
cp /home/mastodon/live/dist/nginx.conf /etc/nginx/sites-available/$INSTANCE.conf
ln -s /etc/nginx/sites-available/$INSTANCE.conf /etc/nginx/sites-enabled/$INSTANCE.conf
sudo vim /etc/nginx/sites-available/$INSTANCE.conf
	# `:s%/example.com/$INSTANCE/g`
	# uncomment "ssl_certificate" and "ssl_certificate_key"
sudo systemctl reload nginx

# Set up systemd services
sudo cp /home/mastodon/live/dist/mastodon-*.service /etc/systemd/system/
sudo systemctl start mastodon-web mastodon-sidekiq mastodon-streaming
#sudo systemctl enable mastodon-*