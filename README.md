# TL;DR  
Mastodon自鯖勢増えろ～というやつ.  

<https://github.com/nesosuke/mastodon-install-script>

- install.sh : 構築に使う  
- update.sh  : アップデートするのに使う  

(注)どちらも`mastodon`ユーザーで実行すること  

## 環境  
Debian 10 on VirtualBox  
Debian 9.7 on ConoHa VPS  

公式インストールガイドはこっち
<https://docs.joinmastodon.org/administration/installation/>  

---  
# 構築
  
## ユーザー`mastodon`の作成  
  ```  
  sudo adduser mastodon
  sudo adduser mastodon sudo
  ``` 

## `install.sh`を実行.  
  ```  
  sudo -u mastodon bash install.sh
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
    - Mailgunなどがあるが,めんどくさがりのぼくはgmailのアカウントを作ってそこからメールが飛ぶようにしている.
    - gmailを使う場合, smtp server: `smtp.gmail.com`, user: `<gmailのユーザー名>@gmail.com`, password: `<gmailのパスワード>` を記入しEnter連打. 
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
bash update.sh
```
- master追従で更新される.
- 安定版でのアップデートの場合はコメントアウトを変更して
```update.sh  
#git pull
git fetch 
git checkout ~~~~
```  
とすること.  

- こちらもビルド時間によっては`sudo`のパスワードを再度入力する必要あり.

---   

