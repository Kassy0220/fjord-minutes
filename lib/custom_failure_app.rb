# frozen_string_literal: true

class CustomFailureApp < Devise::FailureApp
  def route(_scope)
    :root_url
  end
end
