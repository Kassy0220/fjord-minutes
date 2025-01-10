# FjordMinutes
フィヨルドブートキャンプのチーム開発プラクティスで行われているミーティングの議事録を作成するアプリケーションです。

## FjordMinutesでできること
- サービスが議事録を自動で作成してくれます
- チームメンバーが、議事録に出席やミーティング内で話す内容を登録することができます
- ファシリテーターは、作成した議事録をGitHub Wikiに出力することができます

## インストールと起動
以下のコマンドで、アプリのセットアップとサーバーの起動を行うことができます。

```
$ git clone https://github.com/Kassy0220/fjord-minutes.git
$ cd fjord-minutes
$ bin/setup
$ bin/dev
```

http://localhost:3000/ にアクセスすると、アプリのトップページが表示されます。

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

| 環境変数名                   | 説明                                                                    | 
| ---------------------------- |-----------------------------------------------------------------------| 
| AUTH_APP_ID                  | GitHub上で作成したOAthアプリのClient ID                                         | 
| AUTH_APP_SECRET              | GitHub上で作成したOAthアプリのClient secrets                                    | 
| KOMAGATA_EMAIL               | 管理者のGitHubアカウントのメールアドレスその1                                            | 
| MACHIDA_EMAIL                | 管理者のGitHubアカウントのメールアドレスその2                                            | 
| KASSY_EMAIL                  | 管理者のGitHubアカウントのメールアドレスその3                                            | 
| BOOTCAMP_WIKI_URL            | [bootcampアプリのWikiリポジトリ](https://github.com/fjordllc/bootcamp/wiki)のURL | 
| AGENT_WIKI_URL               | [agentアプリのWikiリポジトリ](https://github.com/fjordllc/agent/wiki)のURL      | 
| GITHUB_USER_NAME             | 議事録をコミットするGitHubアカウントのユーザー名                                           | 
| GITHUB_USER_EMAIL            | 議事録をコミットするGitHubアカウントのメールアドレス                                         | 
| GITHUB_ACCESS_TOKEN          | GitHubアクセストークン                                                        | 
| RAILS_COURSE_CHANNEL_URL     | Discordの`チーム開発-bootcamp`チャンネルのWebhook URL                             | 
| FRONT_END_COURSE_CHANNEL_URL | Discordの`チーム開発-agent`チャンネルのWebhook URL                                | 
| TEAM_MEMBER_ROLE_ID          | Discordの`スクラムチーム`ロールのID                                               | 

詳しくは[環境変数の詳細](https://github.com/Kassy0220/fjord-minutes/wiki/%E7%92%B0%E5%A2%83%E5%A4%89%E6%95%B0%E3%81%AE%E8%A9%B3%E7%B4%B0)を参照してください。

## 環境構築
- [Development環境でログインする方法](https://github.com/Kassy0220/fjord-minutes/wiki/Development%E7%92%B0%E5%A2%83%E3%81%A7%E3%83%AD%E3%82%B0%E3%82%A4%E3%83%B3%E3%81%99%E3%82%8B%E6%96%B9%E6%B3%95)

## 技術スタック
- Ruby 3.3.5
- Ruby on Rails 7.2.1
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
