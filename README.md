# Mastodon-install-script

Scritpts to easily deploy Mastodon on Ubuntu.
I hope it will be useful for you.

**NOTE: By using this script, Mastodon will be installed on non-docker environment.**

[![ManHours](https://manhours.aiursoft.cn/gitlab/gitlab.aiursoft.cn/anduin/Mastodon-install-script)](https://gitlab.aiursoft.cn/anduin/Mastodon-install-script/-/commits/master?ref_type=heads)

## Usage

### Install Mastodon

1. Create user `mastodon` and add sudoers.

```bash
# adduser mastodon
# adduser mastodon sudo
```

2. Change user to `mastodon` and clone this repository.

```bash
# su - mastodon
cd ~
git clone https://github.com/nesosuke/mastodon-install-script.git
```

3. Run `install.sh`.
   This script will ask you to enter the server's domain name and email address of the administrator.

```bash
cd mastodon-install-script
./install.sh
```

4. Follow the interactive instructions.
   This will create `.env.production`[^setup].

[^setup]: <https://docs.joinmastodon.org/admin/install/#generating-a-configuration>

### Update Mastodon

1. Change user to `mastodon` and clone this repository.

```bash
# su - mastodon
cd ~
git clone https://github.com/nesosuke/mastodon-install-script.git
```

2. Run `update.sh`.

```bash
cd mastodon-install-script
./update.sh
```

## Reference

- Mastodon(github repo) <https://github.com/mastodon/mastodon>
- Official Installation Manual <https://docs.joinmastodon.org/admin/install/>
