#!/bin/sh

cd ~

# Install curl
sudo apt update
sudo apt upgrade
sudo apt install -f git vim curl npm
	# Install more pkgs, if you need
	# `sudo apt install 

# Extend swapfile
sudo vim /etc/dphys-swapfile
	# "CONF_SWAPSIZE": 100-->2048
sudo systemctl restart dphys-swapfile


# If error occured, check the latest version at https://nodejs.org/dist/latest-v8.x/
#wget https://nodejs.org/dist/latest-v8.x/node-v8.15.0-linux-armv6l.tar.gz
#wget https://nodejs.org/dist/latest-v8.x/node-v8.16.0-linux-x64.tar.gz
#tar -zxvf node-v8.*.tar.gz
#sudo cp -R node-v8.*/* /usr/local/
#sudo ln -s /usr/local/bin/npm /usr/bin/npm

# If the versions are printed, installation of node & npm has been succeeded.
node -v
npm -v

### Notice: Above steps are almost the same as the official documentation. 

# Install yarn
sudo npm install -g yarn 
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
  libidn11-dev libicu-dev libjemalloc-dev rbenv

# Install rbenv and rbenv-build 
# `rbenv install` will take a lot of time. Drink some tea.
#rm -rf ~/.rbenv
#git clone https://github.com/rbenv/rbenv.git ~/.rbenv
#cd ~/.rbenv && src/configure && make -C src
#echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
#echo 'eval "$(rbenv init -)"' >> ~/.bashrc
echo 'run install-mastodon-part2.sh'
cd ~/git/mastodon-install-script
