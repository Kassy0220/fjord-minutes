class AddMeetingRefToMinutes < ActiveRecord::Migration[7.2]
  def change
    add_reference :minutes, :meeting, null: false, foreign_key: true
  end
end
