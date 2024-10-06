class Topic < ApplicationRecord
  belongs_to :minute

  validates :content, presence: true
end
