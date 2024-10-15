class Topic < ApplicationRecord
  belongs_to :minute
  belongs_to :topicable, polymorphic: true

  validates :content, presence: true
end
