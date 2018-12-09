# NOTICE
This script is only for RasPi (ARMv6).  
In case of me, I executed on `RasPi zero w` and `Raspbian Stretch based on Debian 9.6`.  

The steps were tested on 8th Dec 2018; latest versions of Mastodon was "v2.6.5", of Ruby was "2.5.3", of yarn was "1.12.3".
  
Official Installaton Documentation; https://docs.joinmastodon.org/administration/installation/#install-fail2ban-so-it-blocks-repeated-login-attempts)  


# Before run install-script.sh  

## Create user "mastodon"
```
sudo adduser mastodon
sudo adduser mastodon sudo 
su - mastodon
```
##  Set Your Instance Name
```
export INSTANCE=YOURINSTANCEDOMAIN  
```  
# Run the script  
```
./install-script.sh
```
