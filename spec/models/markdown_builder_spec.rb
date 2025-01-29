# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MarkdownBuilder, type: :model do
  let(:rails_course) { FactoryBot.create(:rails_course) }
  let(:minute) { FactoryBot.create(:minute, course: rails_course) }
  let(:alice) { FactoryBot.create(:member, course: rails_course) }
  let(:bob) { FactoryBot.create(:member, :another_member, course: rails_course) }
  let(:absentee) { FactoryBot.create(:member, :absent_member, course: rails_course) }

  it 'returns markdown of minute' do
    FactoryBot.create(:attendance, member: alice, minute:)
    FactoryBot.create(:attendance, :night, member: bob, minute:)
    FactoryBot.create(:attendance, :absence_with_multiple_progress_reports, member: absentee, minute:)
    FactoryBot.create(:topic, :by_member, minute:, topicable: alice)

    expected = <<~MARKDOWN
      # ふりかえり

      ## 出席者

      - [@komagata](https://github.com/komagata)(スクラムマスター)
      - [@machida](https://github.com/machida)(プロダクトオーナー)

      ### 昼の部

      - alice

      ### 夜の部

      - bob

      ## 欠席者

      - absentee
        - 欠席理由
          - 職場のイベントに参加するため。
        - 進捗報告
          - #8000 チームメンバーにレビュー依頼を行いました。
          - #8102 問題が発生している箇所の調査を行いました。
          - #8080 依頼されたレビュー対応を行いました。

      ## デモ

      今回のイテレーションで実装した機能をプロダクトオーナーに向けてデモします。（画面共有使用）
      「お客様」相手にデモをするという設定なので、MTG前に事前に準備をしておくといいかもしれません。
      テストデータなどは事前に準備しておいてください。

      ## 今週のリリースの確認

      木曜日の15時頃リリースします

      - リリースブランチ
        - https://example.com/fjordllc/bootcamp/pull/1000
      - リリースノート
        - https://example.com/announcements/100

      ## 話題にしたいこと・心配事

      明確に共有すべき事・困っている事以外にも、気分的に心配な事などを話すためにあります。

      - gitのブランチ履歴がおかしくなってしまったので、どなたかペアプロをお願いしたいです(alice)

      ## その他

      連絡事項は特にありません

      # 次回のMTG

      - 2024年10月16日(水)
        - 昼の部：15:00-16:00
        - 夜の部：22:00-23:00

      # 計画ミーティング

      - プランニングポーカー
    MARKDOWN
    expect(described_class.build(minute)).to eq expected
  end

  it 'warning text is added when next meeting date is holiday' do
    minute.update!(next_meeting_date: Time.zone.local(2024, 11, 3))
    warning_text = <<~TEXT
      - 2024年11月03日(日)
        - 次回開催日は文化の日です。もしミーティングをお休みにする場合は、開催日を変更しましょう。
    TEXT
    expect(described_class.build(minute)).to include(warning_text)
  end

  it 'does not include unexcused absentee' do
    FactoryBot.create(:member, :unexcused_absent_member, course: rails_course)
    expect(described_class.build(minute)).not_to include('- unexcused_absentee')
  end
end
