# Mastodon鯖構築支援スクリプト  
[![GitHub release (latest by date)](https://img.shields.io/github/v/release/nesosuke/mastodon-install-script)][releases]
[![branch update-stable](https://img.shields.io/badge/branch-update--stable-blueviolet)][update-stable]  

[releases]: https://github.com/nesosuke/mastodon-install-script/releases
[update-stable]: https://github.com/nesosuke/mastodon-install-script/tree/update-stable  

**stableで構築する場合は[`update-stable`](https://github.com/nesosuke/mastodon-install-script/tree/update-stable)ブランチをお使いください。**

## 注
クソ不安定なのでエラーとか起きたりします。(無保証)  
Issueか [nesosuke@twitter](http://twitter.com/@nesosuke) まで。  


## 目的  
Mastodonサーバーがじゃかじゃか生えてほしいので。  

## スクリプトについて  
- install.sh : 構築に使う  
- update.sh  : アップデートするのに使う  

(注)どちらも`mastodon`ユーザーで実行すること  

## 動作確認済み環境  
- Debian 10 on ConoHa VPS

## Mastodon本家について
- リポジトリ: <https://github.com/tootsuite/mastodon>
- インストールガイド: <https://docs.joinmastodon.org/administration/installation/>  

---  
# 構築
  
## ユーザー`mastodon`の作成  
  ```  
  sudo adduser mastodon
  sudo adduser mastodon sudo
  ``` 

## `install.sh`を実行.  
  ```  
  su mastodon
  git clone https://github.com/nesosuke/mastodon-install-script 
  mastodon-install-script/install.sh
  ```  

## サーバードメインの指定
Input your server domain と聞かれるので,立てたいサーバーのドメインを指定する.  
httpsはつけず, `mstdn.example.com` のみで書く.   

```  
  Input your server domain w/o "http" (e.g. mstdn.example.com) > mstdn.exmple.com
```  

## SSL証明書を発行する(選択)
Obtain SSL Cert ? [y/N] と聞かれるので,前項で指定したドメインでSSL証明書を同時に取得する場合のみ`y`または`Y`とする.  
  すでに発行しているものや別途発行する場合は`N`とする.  

## RubyのインストールやMastodonのコンパイル
待つ.     
特にやることはないが,ビルド時間によっては`sudo`のパスワードを再度入力する必要あり.  

## Mastodonの初期設定  
1. ドメインを聞かれるので最初に記入したドメインと同じものを書く.  
1. シングルユーザモードかどうか聞かれる. 自分だけで使うなら`y`.  
1. DBやREDISの項目はEnter連打でもいい. 外に出すなら適宜設定する.  
1. サーバーから送られるメールについての設定を聞かれる.  
    - アカウントのパスワードを忘れたときや,他のMastodonサーバーからの通報の通知を受けられる.  
    - Enter連打でもMastodonは使えるが設定するべき.  
    - Mailgunなどがあるが,gmailアカウントを設定することも可能.
    - gmailを使う場合, smtp server: `smtp.gmail.com`, user: `<gmailのユーザー名>@gmail.com`, password: `<gmailのパスワード>` を入力.  
    - smtp authentication: `plain`, verify mode: `none`でもよい.  
    - smtp from address はメールの差出人名を変えられる.お好みで.  
1. 以上の設定が終わると管理者アカウントの作成を聞かれる.  
    - デフォルトIDは`admin`　　
    - **シングルユーザモードで使う場合には,ここを自分が使うつもりのIDに変えておく.** 
    - 初回ログイン用のワンタイムパスワードが発行されるのでこれでログインすると自分だけのMastodonサーバーが使えるようになる.(ログインしたらパスワードを変えておくこと)   
1. 最後にMastodon用のDBの作成とMastodonのコンパイルをするか聞かれるので,どちらも`y`とする.  
1. 全行程おわり.おつかれさまでした.  

---  

# アップデート  
```  
mastodon-install-script/update.sh
```
---   

