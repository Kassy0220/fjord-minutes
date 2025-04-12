# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NotificationMessageBuilder, type: :model do
  describe '#build' do
    let(:rails_course) { FactoryBot.create(:rails_course) }
    let(:front_end_course) { FactoryBot.create(:front_end_course) }
    let(:minute) { FactoryBot.create(:minute, course: rails_course) }

    before do
      allow(ENV).to receive(:fetch).and_call_original
      allow(ENV).to receive(:fetch).with('TEAM_MEMBER_ROLE_ID', nil).and_return('12345')
    end

    it 'creates notification message of minute creation', skip: 'this class is removed later' do
      expected = <<~MESSAGE
        <@&12345>
        Railsエンジニアコースのチーム開発メンバーに連絡です。

        次回のミーティングの議事録が作成されました。
        次回のミーティングは2024年10月02日(水)に開催されます。

        ミーティングが開催されるまでに、以下のページから、ミーティングの出欠登録と話題にしたいこと・心配事の記入をお願いします。

        出欠登録URL : http://localhost:3000/minutes/#{minute.id}/attendances/new
      MESSAGE
      expect(described_class.build(:minute_creation, rails_course, minute)).to eq expected
    end

    it 'creates today meeting notification message', skip: 'this class is removed later' do
      expected = <<~MESSAGE
        <@&12345>
        Railsエンジニアコースのチーム開発メンバーに連絡です。

        本日チーム開発ミーティングが開催されます。
        - 昼の部 : 15:00 - 16:00
        - 夜の部 : 22:00 - 23:00

        ミーティングの出欠登録と話題にしたいこと・心配事をまだ記入されていない方は、登録と記入をお願いします。

        出欠登録URL : http://localhost:3000/minutes/#{minute.id}/attendances/new
      MESSAGE
      expect(described_class.build(:today_meeting, rails_course, minute)).to eq expected
    end
  end
end
