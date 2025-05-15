# FjordMinutes
フィヨルドブートキャンプのチーム開発プラクティスで行われているミーティングを、議事録の作成と出席管理でサポートするサービスです。

## FjordMinutes でできること
### 議事録を自動で作成
ミーティングが行われた翌日に、次回のミーティングの議事録が自動で作成されます。

議事録が作成されるとDiscordに通知が送られます。

<img width="80%" alt="Discord通知" src="https://github.com/user-attachments/assets/02c0b33a-1991-44a4-9491-e69245054040">

### ミーティングに出席を登録
出席登録ページからミーティングに出席登録を行うことができます。

<img width="80%" alt="出席登録画面" src="https://github.com/user-attachments/assets/b7ad9d66-6ed5-46ff-9b77-ba3ab48d680a">

チームメンバーの出席は記録され、一覧で確認することが可能です。

<img width="80%" alt="チームメンバーの全出席" src="https://github.com/user-attachments/assets/d1a0f2a8-4f2c-40f1-82e2-6ade24573eb0">

### 議事録を編集
議事録の内容を編集することができます(管理者とチームメンバーで編集できる内容は異なります)。

<img width="80%" alt="議事録編集画面" src="https://i.gyazo.com/4bd955b793702ae27d59ae3361926a3e.gif">

### 議事録をGitHub Wikiに反映
管理者は議事録をGitHubリポジトリのWikiに反映させることが可能です。

<img width="80%" alt="GitHubWikiにエクスポートするボタン" src="https://github.com/user-attachments/assets/fc82e505-3cbc-409d-bebb-c748d3219f12">

## インストールと起動
以下のコマンドで、アプリのセットアップとサーバーの起動を行うことができます。

```
$ git clone https://github.com/Kassy0220/fjord-minutes.git
$ cd fjord-minutes
$ bin/setup
$ bin/dev
```

http://localhost:3000/ にアクセスすると、アプリのトップページが表示されます。

### リアルタイム反映機能
議事録編集ページでは、議事録を変更するとそれが他のブラウザ上でもリアルタイムで反映されるようになっています。

この機能を利用するためにはRedisが必要となります。

Redisのインストールと起動方法については、以下のページを参考にしてください。

[Install Redis \| Docs](https://redis.io/docs/latest/operate/oss_and_stack/install/install-redis/)

## Lint
以下のコマンドでLinterを実行することができます。
```
$ bin/run_lint
```

実行されるLinterは次の通りです。
- Ruby
  - rubocop
  - erb_lint
- JavaScript
  - eslint
  - prettier

## Test
以下のコマンドでテストを実行することが可能です。
```
$ bin/rspec
```

## 環境変数
アプリ内では以下の環境変数が利用されます。

| 環境変数名                               | 説明                                                                     | 
|-------------------------------------|------------------------------------------------------------------------| 
| AUTH_APP_ID                         | GitHub上で作成したOAthアプリのClient ID                                          | 
| AUTH_APP_SECRET                     | GitHub上で作成したOAthアプリのClient secrets                                     | 
| KOMAGATA_EMAIL                      | 管理者のGitHubアカウントのメールアドレスその1                                             | 
| MACHIDA_EMAIL                       | 管理者のGitHubアカウントのメールアドレスその2                                             | 
| KASSY_EMAIL                         | 管理者のGitHubアカウントのメールアドレスその3                                             | 
| BOOTCAMP_WIKI_URL                   | [bootcampアプリのWikiリポジトリ](https://github.com/fjordllc/bootcamp/wiki)のURL | 
| AGENT_WIKI_URL                      | [agentアプリのWikiリポジトリ](https://github.com/fjordllc/agent/wiki)のURL       | 
| GITHUB_USER_NAME                    | 議事録をコミットするGitHubアカウントのユーザー名                                            | 
| GITHUB_USER_EMAIL                   | 議事録をコミットするGitHubアカウントのメールアドレス                                          | 
| GITHUB_APP_ID                       | GitHub APPのID                                                          | 
| GITHUB_APP_INSTALLATIONS_ID         | GitHub APPのインストールID                                                    |
| RAILS_COURSE_CHANNEL_URL            | Discordの`チーム開発-bootcamp`チャンネルのWebhook URL                              | 
| FRONT_END_COURSE_CHANNEL_URL        | Discordの`チーム開発-agent`チャンネルのWebhook URL                                 | 
| RAILS_COURSE_SCRUM_TEAM_ROLE_ID     | Discordの`bootcampスクラムチーム`ロールのID                                        | 
| FRONT_END_COURSE_SCRUM_TEAM_ROLE_ID | Discordの`agentスクラムチーム`ロールのID                                           |

詳しくは[環境変数の詳細](https://github.com/Kassy0220/fjord-minutes/wiki/%E7%92%B0%E5%A2%83%E5%A4%89%E6%95%B0%E3%81%AE%E8%A9%B3%E7%B4%B0)を参照してください。

## 環境構築
- [Development環境でログインする方法](https://github.com/Kassy0220/fjord-minutes/wiki/Development%E7%92%B0%E5%A2%83%E3%81%A7%E3%83%AD%E3%82%B0%E3%82%A4%E3%83%B3%E3%81%99%E3%82%8B%E6%96%B9%E6%B3%95)

## 技術スタック
- Ruby 3.4.2
- Ruby on Rails 7.2.2.1
- jsbundling-rails
    - esbuild
- Hotwire
    - turbo-rails
- TailwindCSS
    - tailwindcss-rails
- React
- redis
- git
- PostgreSQL

### 認証
- Devise
- omniauth
- omniauth-github
- omniauth-rails_csrf_protection

### Linter/Formatter
- rubocop
- erb_lint
- eslint
- prettier

### テスト
- RSpec
- FactoryBot

### CI/CD
- GitHub Actions

### インフラ
- Heroku
