# frozen_string_literal: true

namespace :meeting do
  desc 'Create minute'
  task prepare_for_meeting: :environment do
    MeetingSecretary.prepare_for_meeting
  end
end