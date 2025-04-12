class AddMeetingRefToAttendances < ActiveRecord::Migration[7.2]
  def change
    add_reference :attendances, :meeting, null: false, foreign_key: true
  end
end
