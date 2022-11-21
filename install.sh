#!/bin/bash
# Input server domain
read -p "Input your server domain without \"http\" (e.g. mastodon.example.com) > " SERVER_FQDN
read -p "Obtain SSL Cert ? [y/N] > " SSL_CERT

if [ "$SSL_CERT" == "y" -o "$SSL_CERT" == "Y" ]
then
  read -p "Input your mail adress > " ADMIN_MAIL_ADDRESS
else
  echo ""
fi

DEBIN_FRONTEND=noninteractive
# Pre-requisite
## system repository
echo "installing pre-requisite"
sudo apt install -y curl wget gnupg apt-transport-https lsb-release ca-certificates
## Node.js v16
curl -sL https://deb.nodesource.com/setup_16.x | sudo -E bash -
## PostgreSQL
wget -O /usr/share/keyrings/postgresql.asc https://www.postgresql.org/media/keys/ACCC4CF8.asc
echo "deb [signed-by=/usr/share/keyrings/postgresql.asc] http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" | sudo tee /etc/apt/sources.list.d/postgresql.list

# Correct permission ~/.config
sudo mkdir -p ~/.config
sudo chown mastodon:mastodon ~/.config

# Clone Mastodon
sudo apt update
sudo apt upgrade -y
sudo apt install -y git curl ufw
echo "cloning mastodon repository"
git clone https://github.com/mastodon/mastodon.git ~/live
cd ~/live

# Install packages
echo "installing packages"
sudo apt install -y \
  imagemagick ffmpeg libpq-dev libxml2-dev libxslt1-dev file git-core \
  g++ libprotobuf-dev protobuf-compiler pkg-config nodejs gcc autoconf \
  bison build-essential libssl-dev libyaml-dev libreadline6-dev \
  zlib1g-dev libncurses5-dev libffi-dev libgdbm-dev \
  nginx redis-server redis-tools postgresql postgresql-contrib \
  certbot python3-certbot-nginx libidn11-dev libicu-dev libjemalloc-dev
## (c.f. https://qiita.com/yakumo/items/10edeca3742689bf073e about not needing to install "libgdbm5")

# Install Ruby and gem(s)
if [ -d ~/.rbenv ]
then
  cd ~/.rbenv
else
  echo "installing rbenv"
  git clone https://github.com/rbenv/rbenv.git ~/.rbenv
  cd ~/.rbenv && src/configure && make -C src
  echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
  echo 'eval "$(rbenv init -)"' >> ~/.bashrc
  git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
fi
echo "installing ruby"
source ~/.bashrc
echo N | RUBY_CONFIGURE_OPTS="--with-jemalloc" rbenv install $(cat ~/live/.ruby-version)
rbenv global $(cat ~/live/.ruby-version)

# Setup ufw
echo y | sudo ufw enable
sudo ufw allow 80
sudo ufw allow 443
sudo ufw allow 22 #sshシャットアウト対策

# Install yarn
echo "installing yarn"
sudo npm install -g yarn
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list

# Obtain SSL Cert
if [ "$SSL_CERT" == "y" -o "$SSL_CERT" == "Y" ]
then
  echo "obtaining SSL Cert"
  sudo certbot certonly -d $SERVER_FQDN -m $ADMIN_MAIL_ADDRESS -n --nginx --agree-tos
  echo "@daily certbot renew --renew-hook \"service nginx restart\"" | sudo tee -a /etc/cron.d/certbot-renew
else
  echo ""
fi
# Setup PostgreSQL
echo "setting up PostgreSQL"
echo "CREATE USER mastodon CREATEDB" | sudo -u postgres psql -f -

# Setup Mastodon
rbenv global $(cat ~/live/.ruby-version)
cd ~/live
echo "setting up Gem"
gem install bundler --no-document
bundle config deployment true
bundle config without 'development test'
bundle install -j$(getconf _NPROCESSORS_ONLN)
yarn install --pure-lockfile --network-timeout 100000
echo "setting up Mastodon"
RAILS_ENV=production bundle exec rake mastodon:setup


# Set up nginx
cp ~/live/dist/nginx.conf ~/live/dist/$SERVER_FQDN.conf
sed -i ~/live/dist/$SERVER_FQDN.conf -e "s/example.com/$SERVER_FQDN/g"
if [ "$SSL_CERT" == "y" -o "$SSL_CERT" == "Y" ]
then
  sed -i ~/live/dist/nginx.conf -e 's/# ssl_certificate/ssl_certificate/g'
else
  echo "" > /dev/null
fi
sudo cp /home/mastodon/live/dist/$SERVER_FQDN.conf /etc/nginx/conf.d/$SERVER_FQDN.conf

# Set up systemd services
echo "setting up systemd services"
sudo cp /home/mastodon/live/dist/mastodon-*.service /etc/systemd/system/
sudo systemctl enable --now mastodon-web.service mastodon-streaming.service mastodon-sidekiq.service
sudo systemctl restart nginx.service

echo "done :tada:"
