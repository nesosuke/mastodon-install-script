#!/bin/bash
# Input server domain
read -p "Input your server domain w/o \"http\"; e.g. example.com > " INSTANCE
read -p "Obtain SSL Cert ? [y/N] > " ANSWER_SSL_CERT

if ["$ANSWER_SSL_CERT" == "y" -o "$ANSWER_SSL_CERT" == "Y" ]
then 
  read -p "Input your mail adress > " EMAIL
else 
  echo ""
fi

# Prepare
sudo adduser mastodon 
sudo adduser mastodon sudo 
sudo apt install -y screen

set -e
# Install Ruby and gem
rm -rf ~/.rbenv
git clone https://github.com/rbenv/rbenv.git ~/.rbenv
git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
cd ~/.rbenv && src/configure && make -C src
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(rbenv init -)"' >> ~/.bashrc
source ~/.bashrc
rbenv install 2.6.3 &


# Install packages
sudo apt update
sudo apt upgrade
sudo apt install -y git vim curl npm ufw
sudo apt install -y \
  imagemagick ffmpeg libpq-dev libxml2-dev libxslt1-dev file git-core \
  g++ libprotobuf-dev protobuf-compiler pkg-config nodejs gcc autoconf \
  bison build-essential libssl-dev libyaml-dev libreadline6-dev \
  zlib1g-dev libncurses5-dev libffi-dev libgdbm-dev \
  redis-server redis-tools postgresql postgresql-contrib \
  libidn11-dev libicu-dev libjemalloc-dev nginx certbot python-certbot-nginx &
## (c.f. https://qiita.com/yakumo/items/10edeca3742689bf073e about not needing to install "libgdbm5")

# Install yarn
sudo npm install -g yarn 
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list

# Obtain SSL Cert
sudo ufw enable 
sudo ufw allow 80
sudo ufw allow 443
if ["$ANSWER_SSL_CERT" == "y" -o "$ANSWER_SSL_CERT" == "Y" ]
then 
  sudo certbot certonly -d $INSTANCE -m $EMAIL -n --nginx --agree-tos
else 
  echo ""
fi 
# Setup PostgreSQL
echo "CREATE USER mastodon CREATEDB" | sudo -u postgres psql -f -

# Setup Mastodon 
git clone https://github.com/tootsuite/mastodon.git ~/live
cd ~/live
git checkout $(git tag -l | grep -v 'rc[0-9]*$' | sort -V | tail -n 1)
wait 
rbenv global 2.6.3 
gem install bundler --no-ri --no-rdoc
gem install bundler
bundle install \
  -j$(getconf _NPROCESSORS_ONLN) \
  --deployment --without development test
yarn install --pure-lockfile --network-timeout 100000
read -p "Press ENTER to run mastodon:setup"
RAILS_ENV=production bundle exec rake mastodon:setup


# Set up nginx
cp ~/live/dist/nginx.conf ~/live/dist/nginx.conf.original
sed -i ~/live/dist/nginx.conf -e "s/example.com/$INSTANCE/g"
sed -i ~/live/dist/nginx.conf -e 's/# ssl_certificate/ssl_certificate/g'
sudo cp ~/live/dist/nginx.conf /etc/nginx/conf.d/$INSTANCE.conf
sudo vim /etc/nginx/conf.d/$INSTANCE.conf
sudo systemctl restart nginx

# Set up systemd services
sudo cp /home/mastodon/live/dist/mastodon-*.service /etc/systemd/system/
sudo systemctl start mastodon-web mastodon-sidekiq mastodon-streaming
sudo systemctl enable mastodon-web.service mastodon-streaming.service mastodon-sidekiq.service


