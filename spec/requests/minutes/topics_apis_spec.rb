# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Minutes::Topics API', type: :request do
  let!(:minute) { FactoryBot.create(:minute) }
  let(:member) { FactoryBot.create(:member) }
  let(:topic) { FactoryBot.create(:topic, :by_member, minute:, topicable: member) }

  before do
    sign_in member
  end

  context 'when create topic' do
    it 'broadcast to subscriber when topic is created' do
      # post api_minute_topics_path(minute) で新しく作成されるデータを期待値に含めることができないので、ブロードキャストで配信されるデータまではテストしない
      expect do
        post api_minute_topics_path(minute), params: { minute_id: minute.id, topic: { content: 'CIでテストが落ちています！' } }
      end.to have_broadcasted_to(minute).from_channel(MinuteChannel)
    end
  end

  context 'when update topic' do
    it 'broadcast to subscriber when topic is updated' do
      broadcasted_data = [{ id: topic.id, content: '話題にしたいこと・心配事を更新しました', topicable_id: topic.topicable.id, topicable_type: 'Member',
                            topicable: { name: topic.topicable.name } }.as_json]
      expect do
        patch api_minute_topic_path(minute, topic), params: { topic: { content: '話題にしたいこと・心配事を更新しました' } }
      end.to have_broadcasted_to(minute).from_channel(MinuteChannel).with(body: { topics: broadcasted_data })
    end
  end

  context 'when destroy topic' do
    it 'broadcast to subscriber when topic is destroyed' do
      broadcasted_data = []
      expect do
        delete api_minute_topic_path(minute, topic)
      end.to have_broadcasted_to(minute).from_channel(MinuteChannel).with(body: { topics: broadcasted_data })
    end
  end
end
