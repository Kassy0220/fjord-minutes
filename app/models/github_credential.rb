# frozen_string_literal: true

class GithubCredential < ApplicationRecord
  belongs_to :admin

  validates :access_token, presence: true
  validates :refresh_token, presence: true
  validates :expires_at, presence: true
end
