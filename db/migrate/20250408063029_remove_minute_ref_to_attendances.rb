class RemoveMinuteRefToAttendances < ActiveRecord::Migration[7.2]
  def change
    remove_reference :attendances, :minute, foreign_key: true
  end
end
