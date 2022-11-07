#!/bin/bash
# Input server domain
read -p "Input your server domain w/o \"http\" (e.g. mstnd.example.com) > " SERVER_DOMAIN
read -p "Obtain SSL Cert ? [y/N] > " getCERT_FLAG

if [ "$getCERT_FLAG" == "y" -o "$getCERT_FLAG" == "Y" ]
then
  read -p "Input your mail adress > " ADMIN_MAIL_ADDRESS
else
  echo ""
fi

# Correct permission ~/.config
sudo mkdir -p ~/.config
sudo chown mastodon:mastodon ~/.config

# Clone Mastodon
sudo apt update
sudo apt upgrade -y
sudo apt install -y git curl ufw
git clone https://github.com/mastodon/mastodon.git ~/live
cd ~/live

# Install packages
curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -
sudo apt install -y npm
sudo apt install -y \
  ufw imagemagick ffmpeg libpq-dev libxml2-dev libxslt1-dev file git-core \
  g++ libprotobuf-dev protobuf-compiler pkg-config nodejs gcc autoconf \
  bison build-essential libssl-dev libyaml-dev libreadline6-dev \
  zlib1g-dev libncurses5-dev libffi-dev libgdbm-dev \
  redis-server redis-tools postgresql postgresql-contrib \
  libidn11-dev libicu-dev libjemalloc-dev nginx

## (c.f. https://qiita.com/yakumo/items/10edeca3742689bf073e about not needing to install "libgdbm5")

set -e
# Install Ruby and gem(s)

if [ -d ~/.rbenv ]
then
  cd ~/.rbenv
else
  git clone https://github.com/rbenv/rbenv.git ~/.rbenv
  git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
  cd ~/.rbenv && src/configure && make -C src
  echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
  echo 'eval "$(rbenv init -)"' >> ~/.bashrc
  source ~/.bashrc
  export  PATH="$HOME/.rbenv/bin:$PATH"
  eval "$(rbenv init -)"
fi
echo N | rbenv install $(cat ~/live/.ruby-version)
rbenv global $(cat ~/live/.ruby-version)

# Setup ufw
printf y | sudo ufw enable
sudo ufw allow 80
sudo ufw allow 443
sudo ufw allow 22 #sshシャットアウト対策

# Install yarn
sudo npm install -g yarn
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list

# Obtain SSL Cert
if [ "$getCERT_FLAG" == "y" -o "$getCERT_FLAG" == "Y" ]
then
  sudo apt install -y certbot python3-certbot-nginx
  sudo certbot certonly -d $INSTANCE -m $EMAIL -n --nginx --agree-tos
  echo "@daily certbot renew --renew-hook \"service nginx restart\"" | sudo tee -a /etc/cron.d/certbot-renew
else
  echo ""
fi
# Setup PostgreSQL
set +e
echo "CREATE USER mastodon CREATEDB" | sudo -u postgres psql -f -
set -e

# Setup Mastodon
rbenv global $(cat ~/live/.ruby-version)
cd ~/live
gem install bundler
bundle install \
  -j$(getconf _NPROCESSORS_ONLN) \
  --deployment --without development test
yarn install --pure-lockfile --network-timeout 100000
RAILS_ENV=production bundle exec rake mastodon:setup


# Set up nginx
cp ~/live/dist/nginx.conf ~/live/dist/$SERVER_DOMAIN.conf
sed -i ~/live/dist/$SERVER_DOMAIN.conf -e "s/example.com/$SERVER_DOMAIN/g"
if [ "$getCERT_FLAG" == "y" -o "$getCERT_FLAG" == "Y" ]
then
  sed -i ~/live/dist/nginx.conf -e 's/# ssl_certificate/ssl_certificate/g'
else
  echo "" > /dev/null
fi
sudo ln -s /home/mastodon/live/dist/$SERVER_DOMAIN.conf /etc/nginx/conf.d/$SERVER_DOMAIN.conf

# Set up systemd services
sudo cp /home/mastodon/live/dist/mastodon-*.service /etc/systemd/system/
sudo systemctl enable --now mastodon-web.service mastodon-streaming.service mastodon-sidekiq.service
sudo systemctl restart nginx.service


