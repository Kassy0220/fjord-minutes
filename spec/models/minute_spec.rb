# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Minute, type: :model do
  describe '#already_finished?' do
    let(:meeting) { FactoryBot.build(:meeting, course: FactoryBot.create(:rails_course)) }
    let(:minute) { FactoryBot.build(:minute, meeting:) }

    it 'returns false if today is before the meeting date' do
      travel_to meeting.date.yesterday do
        expect(minute.already_finished?).to be false
      end
    end

    it 'returns false if today is the meeting date' do
      travel_to meeting.date do
        expect(minute.already_finished?).to be false
      end
    end

    it 'returns true if today is after the meeting date' do
      travel_to meeting.date.tomorrow do
        expect(minute.already_finished?).to be true
      end
    end
  end

  describe '#title' do
    it 'returns formatted minute title' do
      minute = FactoryBot.build(:minute, meeting: FactoryBot.build(:meeting, date: Time.zone.local(2025, 1, 8)))
      expect(minute.title).to eq 'ふりかえり・計画ミーティング2025年01月08日'
    end
  end

  describe '#to_markdown' do
    let(:rails_course) { FactoryBot.create(:rails_course) }
    let(:meeting) { FactoryBot.create(:meeting, course: rails_course) }
    let(:minute) { FactoryBot.create(:minute, meeting:) }

    it 'returns markdown of minute' do
      alice = FactoryBot.create(:member, course: rails_course)
      FactoryBot.create(:attendance, member: alice, meeting: meeting)
      FactoryBot.create(:attendance, :night, member: FactoryBot.create(:member, :another_member, course: rails_course), meeting: meeting)
      FactoryBot.create(:attendance, :absence_with_multiple_progress_reports, member: FactoryBot.create(:member, :absent_member, course: rails_course), meeting: meeting)
      FactoryBot.create(:topic, :by_member, minute: minute, topicable: alice)

      expected = <<~MARKDOWN
        # ふりかえり

        ## 出席者

        - [@komagata](https://github.com/komagata)(スクラムマスター)
        - [@machida](https://github.com/machida)(プロダクトオーナー)

        ### 昼の部

        - [@alice](https://github.com/alice)

        ### 夜の部

        - [@bob](https://github.com/bob)

        ## 欠席者

        - [@absentee](https://github.com/absentee)
          - 欠席理由
            - 職場のイベントに参加するため。
          - 進捗報告
            - [#8000](https://github.com/fjordllc/bootcamp/issues/8000) チームメンバーにレビュー依頼を行いました。
            - [#8102](https://github.com/fjordllc/bootcamp/issues/8102) 問題が発生している箇所の調査を行いました(関連Issue[#8100](https://github.com/fjordllc/bootcamp/issues/8100))。
            - [#8080](https://github.com/fjordllc/bootcamp/issues/8080) 依頼されたレビュー対応を行いました。

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

        ## 次回のMTG

        - 2024年10月16日(水)
          - 昼の部：15:00-16:00
          - 夜の部：22:00-23:00

        # 計画ミーティング

        - プランニングポーカー
      MARKDOWN
      expect(minute.to_markdown).to eq expected
    end

    it 'warning text is added when next meeting date is holiday' do
      meeting.update!(next_date: Time.zone.local(2024, 11, 3))
      warning_text = <<~TEXT
        - 2024年11月03日(日)
          - 次回開催日は文化の日です。もしミーティングをお休みにする場合は、開催日を変更しましょう。
      TEXT
      expect(minute.to_markdown).to include(warning_text)
    end

    it 'does not include unexcused absentee' do
      FactoryBot.create(:member, :unexcused_absent_member, course: rails_course)
      expect(minute.to_markdown).not_to include('- unexcused_absentee')
    end
  end
end
